class Account
  include Mongoid::Document
  
  field :name, :type => String
  field :webkey, :type => String
  
  validates_presence_of :name
  #validates_presence_of :webkey
  
  has_many_related :transactions
  
  before_validate :set_webkey_from_name, :unless => :webkey?
  
  def set_webkey_from_name
    self.webkey = name.downcase
  end
end