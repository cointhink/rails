class Authorization < ActiveRecord::Base
  belongs_to :user
  belongs_to :acl_flag
end