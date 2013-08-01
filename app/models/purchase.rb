class Purchase < ActiveRecord::Base
  attr_accessible :disbursement_tx, :amount, :purchasable
  belongs_to :amount, :class_name => :Balance, :dependent => :destroy
  belongs_to :purchasable, :polymorphic => true

  validates :amount, :presence => true
end
