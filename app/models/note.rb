class Note < ActiveRecord::Base
  attr_accessible :text, :category
  belongs_to :notable, :polymorphic => true
end
