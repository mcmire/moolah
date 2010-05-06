class Money
  def self.from_mongo(value)
    Money === value ? value : Money.new(value)
  end
  
  def self.to_mongo(value)
    from_mongo(value).amount
  end
  
  attr_reader :value, :type, :amount
  
  def initialize(args_or_cents)
    return unless args_or_cents
    case args_or_cents
    # Really? We really have to have this?
    #when Money
    #  @value = args_or_cents.value
    #  @type = args_or_cents.type
    #  @amount = args_or_cents.amount
    when Hash
      args = args_or_cents
      args.stringify_keys!
      requires!(args, %w(value type), "Invalid hash given to Money.new")
      @value = args["value"].to_s
      @type = args["type"].to_s
      @amount = (@value.to_f * 100 * (@type == "debit" ? -1 : 1)).to_i
    when Fixnum
      @amount = args_or_cents
      @value = "%.2f" % (@amount.abs / 100.0)
      @type = @amount > 0 ? "credit" : "debit"
    else
      raise ArgumentError, "Money.new takes either a hash or an integer, but you gave #{args_or_cents.inspect}"
    end
  end
  
  def value_as_currency
    return unless value
    (@type == "debit" ? "-" : "") + "$" + value
  end
  
  def ==(other)
    Money === other ? amount == other.amount : amount == other
  end
  
  def to_s
    @amount.to_s
  end
  
private
  def requires!(hash, required_keys, message)
    # assume keys are already stringified
    invalid_keys = required_keys - hash.keys
    unless invalid_keys.empty?
      error_message = "%s.\nRequired keys are %s, but you gave %s." % [
        message,
        required_keys.map {|x| x.inspect }.join(', '),
        hash.keys.map {|x| x.inspect }.join(', ')
      ]
      raise ArgumentError, error_message
    end
  end
end