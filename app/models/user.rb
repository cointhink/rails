class User < ActiveRecord::Base
  attr_accessible :username, :email, :encrypted_password
  validates :username, :email, :presence => true, :uniqueness => true
  validates :username, :length => { :minimum => 2 }
  validates :username, :format => {:with => /^\w+$/,
                                   :message => "letter numbers and underscore only"}
  validates :email, :format => { :with => /@/ }
  validates :encrypted_password, :presence => true

  has_many :authorizations
  has_many :acl_flags, :through => :authorizations
  has_many :scripts

  extend FriendlyId
  friendly_id :username, use: :slugged

  def self.safe_create(params)
    user = User.new
    user.username = params[:username]
    user.email = params[:email]
    if params[:password].length >= 6
      user.encrypted_password = BCrypt::Password.create(params[:password])
    end
    if user.valid?
      coin_accounts_success = setup_coin_accounts(user.username)
      unless coin_accounts_success
        # error alert
      end
    end
    user.save
    user
  end

  def self.setup_coin_accounts(username)
    begin
      COIND.keys.each do |coin|
        coind_result = COIND[coin].add_user(username)
        if coind_result["receiving_addresss"]
          true
        end
      end.all?
    rescue Errno::ECONNREFUSED, RestClient::RequestTimeout
      return false
    end
  end

  def authentic?(password)
    BCrypt::Password.new(encrypted_password) == password
  end

  def acl_flag?(name)
    flag = AclFlag.find_by_name(name)
    if flag
      acl_flags.include?(flag)
    end
  end

end
