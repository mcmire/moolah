class Time
  SQL_TIME_REGEX = %r{
    (\d+) - (\d+) - (\d+)
    (?: \s+ (\d+) : (\d+) : (\d+) )?
  }x
  STD_TIME_REGEX = %r{
    (\d+) / (\d+) / (\d+)
    (?: \s+ (\d+) : (\d+) : (\d+) )?
  }x
  
  def self.fast_parse(str)
    if m = str.match(SQL_TIME_REGEX)
      a = m.captures.compact
    elsif m = str.match(STD_TIME_REGEX)
      a = m.captures.compact
      a[0..2] = a[2], a[0], a[1]
    else
      return
    end
    a[0] = "20#{a[0]}" if a[0].length == 2
    Time.local(*a.map(&:to_i)) rescue nil
  end
end

class Date
  def self.fast_parse(str)
    Time.fast_parse(str).to_date
  end
  
  def at_beginning_of_week
    self - wday
  end
  
  def at_end_of_week
    at_beginning_of_week + 6
  end
end