class Script < ActiveRecord::Base
  attr_accessible :name, :url

  validates :name, :presence => true, :uniqueness => {:scope => :user_id}

  belongs_to :user

  extend FriendlyId
  friendly_id :name, use: :slugged

  def self.safe_create(params)
    script = Script.new
    script.name = params[:name]
    script.save
    script
  end
end
