class TransactionType
  TYPES = {
    1 => "automatic deposit",
    2 => "manual deposit",
    3 => "online payment",
    4 => "check card (in person)",
    5 => "check",
    6 => "manual withdrawal",
    7 => "transferral"
  }
  
  def self.find(id)
    TYPES[id]
  end
end