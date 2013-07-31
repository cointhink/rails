class Purchase < ActiveRecord::Base
  attr_accessible :disbursement_tx
  belongs_to :amount, :class_name => :Balance, :dependent => :destroy
  belongs_to :purchaseable, :polymorphic => true

  validates :amount, :presence => true
end
