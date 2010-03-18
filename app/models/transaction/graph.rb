class Transaction
  class Graph
    class TimeBasedIterator
      class Slice < Array
        def start_date
          first.x
        end
        def end_date
          last.x
        end
        def first_known_point
          find {|p| p && p.y }
        end
        def last_known_point
          reverse.find {|p| p && p.y }
        end
        def known_start_date
          first_known_point.x
        end
        def known_end_date
          last_known_point.x
        end
      end

      def initialize(data, start_date, end_date)
        @data = data
        @start_date = start_date
        @end_date = end_date
      end

      def iterate_by(options, &block)
        is_cumulative = options.delete(:cumulative)
        num_points = @data.size
        i = j = 0
        slices = []
        slice = Slice.new
        date = @start_date
        end_date = date.advance(options.dup)
        while i < num_points && date < end_date && date < @end_date
          loop do
            point = @data[i]
            if point
              date = point.x
            else
              date += 1
            end
            break unless date < end_date && date < @end_date
            slice << point

            i += 1
          end

          yield slice

          if is_cumulative
            end_date = end_date.advance(options.dup)
          else
            date = end_date
            end_date = date.advance(options.dup)
            slice.clear
          end
        end
        j += 1
      end
    end

    class Point < Array
      def initialize(x, y)
        super([x, y])
      end
      def x
        self[0]
      end
      def y
        self[1]
      end
    end
    
    class << self
      
      def get_balance_data
        txns = Transaction.all(:order => "settled_on")
        assemble_balance_data(txns)
      end
      
      def get_checking_balance_data
        txns = Transaction.all(:account_id => "checking", :order => "settled_on")
        assemble_balance_data(txns)
      end
      
      def get_savings_balance_data
        txns = Transaction.all(:account_id => "savings", :order => "settled_on")
        assemble_balance_data(txns)
      end
      
    private
      
      def assemble_balance_data(all_txns)
        return [] if all_txns.empty?
        
        dates = all_txns.map(&:settled_on)
        inner_window = dates.min .. dates.max
        outer_window = inner_window.begin.at_beginning_of_month .. inner_window.end.at_end_of_month
        
        # Squash days
        txns = all_txns.inject({}) {|h,t| h[t.settled_on] ||= 0; h[t.settled_on] += (t.amount / 100.0); h }
        
        # Fill in the gaps in time
        points = []
        i = 0
        sum = 0
        #txns.keys.sort.each_with_index do |date, i|
        #  amount = txns[date]
        #  if i > 0
        #    points << Point.new((date-1).to_time.to_i * 1000, sum)
        #  end
        #  sum += amount
        #  points << Point.new(date.to_time.to_i * 1000, sum)
        #end
        outer_window.each do |date|
          amount = txns[date]
          if amount
            # something happened today, let's show it and update running total.
            sum += amount
            balance = sum
          elsif date < inner_window.begin
            # we haven't started counting yet, skip ahead until we hit a point.
            next
          elsif date > inner_window.end
            # no more transactions, let's end this.
            break
          else
            # no transactions today. keep same balance.
            balance = sum
          end
          points << Point.new(date, balance)
        end
        points
      end
      
    end
  end
end