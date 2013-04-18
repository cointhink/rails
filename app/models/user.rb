class User < ActiveRecord::Base
  attr_accessible :username, :email, :encrypted_password
  validates :username, :email, :presence => true, :uniqueness => true
  validates :username, :length => { :minimum => 2 }
  validates :email, :format => { :with => /@/ }
  validates :encrypted_password, :presence => true

  def self.safe_create(params)
    user = User.new
    user.username = params[:username]
    user.email = params[:email]
    if params[:password].length >= 6
      user.encrypted_password = BCrypt::Password.create(params[:password])
    end
    user.save
    user
  end

  def authentic?(password)
    BCrypt::Password.new(encrypted_password) == password
  end
end
