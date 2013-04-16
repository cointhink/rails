class User < ActiveRecord::Base
  attr_accessible :username, :email, :encrypted_password
  validates :username, :email, :uniqueness => true

  def self.safe_create(params)
    user = User.new
    user.username = params[:username]
    user.email = params[:email]
    user.encrypted_password = BCrypt::Password.create(params[:password])
    user.save
    user
  end

  def authentic?(password)
    BCrypt::Password.new(encrypted_password) == password
  end
end
