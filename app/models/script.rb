class Script < ActiveRecord::Base
  attr_accessible :name, :url

  validates :name, :presence => true, :uniqueness => {:scope => :user_id}

  scope :valid, lambda { where("deleted = ?", false) }

  belongs_to :user
  has_many :runs, :class_name => 'ScriptRun'

  extend FriendlyId
  friendly_id :name, use: :slugged

  def self.safe_create(params)
    script = Script.new
    #defaults
    script.deleted = false

    script.name = params[:name]
    script.save
    script
  end

  def safe_update(params)
    if params[:name]
      self.name = params[:name]
    end
    save
  end

end
