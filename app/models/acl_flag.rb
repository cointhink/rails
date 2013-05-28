class AclFlag < ActiveRecord::Base
  attr_accessible :name
  
	has_many :authorizations
	has_many :users, :through => :authorizations
end
