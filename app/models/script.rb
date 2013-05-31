class Script < ActiveRecord::Base
  attr_accessible :name, :url

  validates :name, :presence => true, :uniqueness => true

  belongs_to :user

  def safe_create(params)
    script = Script.new
    script.name = params[:name]
    script.save
    script
  end
end
