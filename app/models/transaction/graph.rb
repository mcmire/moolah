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
        num_data = @data.size
        i = j = 0
        slices = []
        slice = Slice.new
        date = @start_date
        end_date = date.advance(options.dup)
        while i < num_data && date < end_date && date < @end_date
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
      
      def balance
        all_txns = get_transactions
        assemble_balance_data(all_txns)
      end
      
      def checking_balance
        all_txns = get_transactions(:account_id => "checking")
        assemble_balance_data(all_txns)
      end
      
      def savings_balance
        all_txns = get_transactions(:account_id => "savings")
        assemble_balance_data(all_txns)
      end
      
      def monthly_income
        all_txns = get_transactions
        
        return {:data => [], :xlabels => []} if all_txns.empty?
        
        #dates = all_txns.map(&:settled_on)
        #inner_window = dates.min .. dates.max
        #outer_window = inner_window.begin.at_beginning_of_month .. inner_window.end.at_end_of_month
        txns = squash_days_and_convert_to_dollars(all_txns)
        
        # Convert money earned/spent to balance
        balance_data = []
        balance = 0
        txns.keys.sort.each do |date|
          amount = txns[date]
          balance += amount
          balance_data << [date, balance]
        end
      
        # Group data by month
        grouped_balance_data = balance_data.inject({}) {|h,(k,v)| (h[k.at_beginning_of_month] ||= []) << v; h }
      
        # Now that we have month groups, we can figure out how much
        # was gained/lost per month
        data = []
        xlabels = []
        last_months_balance = 0
        grouped_balance_data.keys.sort.each do |month|
          balances = grouped_balance_data[month]
          diff = balances.last - last_months_balance
          data << diff
          xlabels << month.strftime("%b %Y")
          last_months_balance = balances.last
        end
        
        #start_of_month = balance_data[:inner_window].begin
        #begin
        #  # Find the data point at the first of the month
        #  balance1 = balance_data[:data][start_of_month]
        #  # Skip to the end of the month, or the end of the data
        #  end_of_month = (start_of_month >> 1) - 1
        #  balance2 = balance_data[:data][end_of_month]
        #  unless balance2
        #    end_of_month = balance_data[:inner_window].end
        #    balance2 = balance_data[:data][end_of_month]
        #  end
        #  # How much did we make this month?
        #  diff = balance2 - balance1
        #  data << diff
        #  xlabels << start_of_month.strftime("%b %Y")
        #  start_of_month = end_of_month + 1
        #end until start_of_month >= balance_data[:inner_window].end
        
        {:data => data, :xlabels => xlabels}
      end
      
    private
    
      def get_transactions(options={})
        Transaction.all({:order => "settled_on"}.merge(options))
      end
      
      # Squash days
      def squash_days_and_convert_to_dollars(all_txns)
        all_txns.inject({}) {|h,t| h[t.settled_on] ||= 0; h[t.settled_on] += (t.amount / 100.0); h }
      end
      
      def assemble_balance_data(all_txns)
        return {:data => []} if all_txns.empty?
        
        dates = all_txns.map(&:settled_on)
        inner_window = dates.min .. dates.max
        outer_window = inner_window.begin.at_beginning_of_month .. inner_window.end.at_end_of_month
        txns = squash_days_and_convert_to_dollars(all_txns)
        
        # Fill in the gaps in time
        data = []
        i = 0
        sum = 0
        #txns.keys.sort.each_with_index do |date, i|
        #  amount = txns[date]
        #  if i > 0
        #    data << Point.new((date-1).to_time.to_i * 1000, sum)
        #  end
        #  sum += amount
        #  data << Point.new(date.to_time.to_i * 1000, sum)
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
          data << [date, balance]
        end
        
        {:data => data}#, :inner_window => inner_window, :outer_window => outer_window}
      end
      
    end
  end
end