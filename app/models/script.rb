class Script < ActiveRecord::Base
  attr_accessible :name, :url, :body

  validates :user_id, :presence => true
  validates :name, :presence => true, :uniqueness => {:scope => :user_id}

  scope :valid, lambda { where("deleted = ?", false) }

  belongs_to :user
  has_many :runs, :class_name => 'ScriptRun'

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

  def self.safe_create(params)
    script = Script.new
    #defaults
    script.deleted = false

    script.name = params[:name]
    script.save
    script
  end

  def safe_update(params)
    unless params[:name].blank?
      self.name = params[:name]
    end
    unless params[:url].blank?
      self.url = params[:url]
      # response = RestClient.get(params[:url])
    end
    unless params[:body].blank?
      self.body = params[:body]
    end
    save
  end

  def start
    unless docker_container_id
      id = build_container
      if id
        logger.info ("Script #{user.username}/#{name} container created id ##{docker_container_id}")
        update_attribute :docker_container_id, id
      else
        # error alert
        logger.error "Script #{user.username}/#{name} cointainer build failed"
        halt
      end
    end
    begin
      result = docker.containers.start(docker_container_id)
      logger.info "start #{docker_container_id} "+result.inspect
    rescue Docker::Error::ContainerNotFound
      # bogus container id
      logger.info "start #{docker_container_id} not found"
      update_attribute :docker_container_id, nil
      halt
    end
  end

  def stop
    if docker_container_id
      begin
        result = docker.containers.stop(docker_container_id)
        logger.info "stop #{docker_container_id} "+result.inspect
      rescue Docker::Error::ContainerNotFound
        # bogus container id, set to stopped anyways
        logger.info "stop #{docker_container_id} not found"
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
    result = docker.containers.create(['sleep 600'], 'busybox')
    logger.info "create "+result.inspect
    result["Id"]
  end
end
