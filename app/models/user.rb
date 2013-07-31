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
  has_many :purchases

  extend FriendlyId
  friendly_id :username, use: :slugged

  def apply_params(params)
    # valid? is always called after this method
    # params is expected to be a complete set of attributes
    self.username = params[:username]
    self.email = params[:email]
    if params[:password] && params[:password].length >= 6
      self.encrypted_password = BCrypt::Password.create(params[:password])
    else
      self.encrypted_password = nil #create a validation error
    end
  end

  def setup_coin_accounts
    begin
      COIND.keys.each do |coin|
        coind_result = COIND[coin].add_user(username)
        if coind_result["receiving_addresss"]
          true
        end
      end.all?
    rescue Errno::ECONNREFUSED, RestClient::RequestTimeout, RestClient::MethodNotAllowed
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

  def balance(currency)
    begin
      coinhash = COIND[currency].user(username)
      my_balance = Balance.new(amount: coinhash['balance']['amount'],
                               currency: coinhash['balance']['currency'])
      my_balance - balance_on_hold(currency)
    rescue Jimson::Client::Error::ServerError,  Errno::ECONNREFUSED => e
    end
  end

  def balance_on_hold(currency)
    purchases.where({disbursement_tx:nil}).reduce(Balance.new({amount:0, currency:currency})) do |m,e|
      m += e.amount
    end
  end
end
