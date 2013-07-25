class Script < ActiveRecord::Base
  attr_accessible :name, :url, :body, :body_url,
                  :docker_host, :docker_container_id, :docker_status

  validates :user_id, :presence => true
  validates :name, :presence => true, :uniqueness => {:scope => :user_id}

  scope :valid, lambda { where("deleted = ?", false) }

  belongs_to :user
  has_many :runs, :class_name => 'ScriptRun'

  after_destroy :rethink_delete

  extend FriendlyId
  friendly_id :name, use: :slugged

  include Workflow
  workflow_column :docker_status

  workflow do
    state :stopped do
      event :start, :transitions_to => :running
    end
    state :running do
      event :stop, :transitions_to => :stopped
    end

  end

  include RethinkDB::Shortcuts

  def self.safe_create(params)
    script = Script.new
    #defaults
    script.deleted = false

    script.name = params[:name]
    script.save
    script
  end

  def safe_update(params)
    unless params[:url].blank?
      self.url = params[:url]
      # response = RestClient.get(params[:url])
    end
    unless params[:body].blank?
      r.table('scripts').get(script_name).update(body:params[:body]).run(R)
    end
    save
  end

  def rethink_insert
    r.table('scripts').insert(id:script_name,
                              key:UUID.generate,
                              inventory: {btc:1},
                              trades: []).run(R)
    r.table('storage').insert({_cointhink_id_:script_name}).run(R)
  end

  def rethink_delete
    r.table('scripts').get(script_name).delete.run(R)
    r.table('storage').get(script_name).delete.run(R)
    r.db('cointhink').
      table('signals').
      get_all(script_name, {index:'name'}).
      delete.
      run(R)
  end

  def reset!
    r.table('storage').get(script_name).replace({'_cointhink_id_'=>script_name}).run(R)
  end

  def script_name
    "#{user.username}/#{name}"
  end

  def doc
    @doc ||= r.table('scripts').get(script_name).run(R)
  end

  def body
    doc["body"]
  end

  def key
    doc["key"]
  end

  def inventory_value_in(currency, rates)
    total = inventory[currency]
    if inventory["usd"]
     total += inventory["usd"] / rates['BTCUSD']
   end
   total
  end

  def inventory
    doc["inventory"]
  end

  def storage
    unless @storage
      @storage = r.table('storage').get(script_name).run(R)
      @storage.delete('_cointhink_id_')
    end
    @storage
  end

  def trades
    doc["trades"]
  end

  def currencies
    inventory.keys
  end

  def start
    if docker_container_id
      # container_id check
      begin
        result = docker.containers.show(docker_container_id)
        logger.info "Script#start #{docker_container_id} check "+result.inspect
      rescue Docker::Error::ContainerNotFound
        logger.error "Script#start #{user.username}/#{name} abandoning cointainer id #{docker_container_id}."
        self.docker_container_id = nil
      end
    end

    unless docker_container_id
      begin
        id = build_container
        if id
          logger.info ("Script#start #{user.username}/#{name} container created id ##{id}")
          update_attribute :docker_container_id, id
        else
          # error alert
          logger.error "Script#start #{user.username}/#{name} cointainer build failed"
          halt
        end
      rescue Docker::Error::NotFoundError => e
        logger.error "Script#start #{user.username}/#{name} cointainer build failed, Not Found "
        halt
      end
    end

    begin
      result = docker.containers.start(docker_container_id)
      logger.info "Script#start #{docker_container_id} start returned "+result.inspect
    rescue Docker::Error::ContainerNotFound
      # bogus container id
      logger.info "Script#start #{docker_container_id} not found"
      update_attribute :docker_container_id, nil
      halt
    rescue Docker::Error::InternalServerError => e
      logger.info "Script#Start InternalServerError: "+e.inspect
    rescue Curl::Err::PartialFileError => e
      logger.info "Script#start PartialFileError: "+e.inspect
    end
  end

  def stop
    if docker_container_id
      begin
        result = docker.containers.stop(docker_container_id)
        logger.info "Script#stop #{docker_container_id} "+result.inspect
      rescue Docker::Error::ContainerNotFound
        # bogus container id, set to stopped anyways
        logger.info "Script#stop container #{docker_container_id} not found"
      rescue Curl::Err::PartialFileError => e
        logger.info "Script#stop PartialFileError: "+e.inspect
      end
    end
  end

  def docker
    host = docker_host || SETTINGS["docker"]["default_host"]
    unless docker_host
      update_attribute :docker_host, host
    end
    Docker::API.new(base_url: "http://#{host}:4243")
  end

  def build_container
    result = docker.containers.create(['ct-g', user.username, name],
                                      SETTINGS["docker"]["image"],
                                      {"Env"=>["cointhink_user_name=#{user.username}",
                                               "cointhink_script_name=#{name}",
                                               "cointhink_script_key=#{key}"],
                                       "PortSpecs"=>["3002"],
                                       "User"=>SETTINGS["docker"]["user"]})
    logger.info "Script#build_container "+result.inspect
    result["Id"]
  end

  def last_signals(count=10, type=nil)
    REDIS.lrange("log:#{script_name}", 0, count).map do |s|
      JSON.parse(s)
    end
  end
end
