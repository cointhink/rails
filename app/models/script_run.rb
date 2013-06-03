class ScriptRun < ActiveRecord::Base
  # attr_accessible :title, :body

  belongs_to :script

  scope :latest, order(:created_at)
end
