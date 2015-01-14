class Blogpost < ActiveRecord::Base
  extend FriendlyId
  attr_accessible :title, :body

  friendly_id :title, use: :slugged
end
