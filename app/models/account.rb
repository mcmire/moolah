class Account
  include MongoMapper::Document
  
  key :name, String, :required => true
  key :webkey, String, :required => true
  
  many :transactions
  
  before_validation :set_webkey_from_name, :unless => :webkey?
  
  def set_webkey_from_name
    self.webkey = name.downcase
  end
end