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
        return {:data => []} if all_txns.empty?
        dates = all_txns.map(&:settled_on)
        inner_window = dates.min .. dates.max
        outer_window = inner_window.begin.at_beginning_of_month .. inner_window.end.at_end_of_month
        data = build_balance_data(all_txns, inner_window, outer_window)
        {:data => data}
      end
      
      def checking_balance
        all_txns = get_transactions(:account_id => "checking")
        return {:data => []} if all_txns.empty?
        dates = all_txns.map(&:settled_on)
        inner_window = dates.min .. dates.max
        outer_window = inner_window.begin.at_beginning_of_month .. inner_window.end.at_end_of_month
        data = build_balance_data(all_txns, inner_window, outer_window)
        {:data => data}
      end
      
      def savings_balance
        all_txns = get_transactions(:account_id => "savings")
        return {:data => []} if all_txns.empty?
        dates = all_txns.map(&:settled_on)
        inner_window = dates.min .. dates.max
        outer_window = inner_window.begin.at_beginning_of_month .. inner_window.end.at_end_of_month
        data = build_balance_data(all_txns, inner_window, outer_window)
        {:data => data}
      end
      
      def monthly_income
        all_txns = get_transactions
        
        return {:data => [], :xlabels => []} if all_txns.empty?
        
        dates = all_txns.map(&:settled_on)
        inner_window = dates.min .. dates.max
        outer_window = inner_window.begin.at_beginning_of_month .. inner_window.end.at_end_of_month
        
        build_income_data(
          all_txns, inner_window, outer_window,
          :get_next_period => lambda {|date| date >> 1 }
        )
      end
      
      def bimonthly_income
        all_txns = get_transactions
        
        return {:data => [], :xlabels => []} if all_txns.empty?
        
        dates = all_txns.map(&:settled_on)
        inner_window = dates.min .. dates.max
        outer_window = inner_window.begin.at_beginning_of_week .. inner_window.end.at_end_of_week
        
        build_income_data(
          all_txns, inner_window, outer_window,
          :get_next_period => lambda {|date| date + 14 }
        )
      end
      
    private
    
      def format_date(date)
        "#{date.month}/#{date.day}/#{date.year.to_s[2..3]}"
      end
    
      def get_transactions(options={})
        Transaction.all({:order => "settled_on"}.merge(options))
      end
      
      # Squash days
      def squash_days_and_convert_to_dollars(all_txns)
        all_txns.inject({}) {|h,t| h[t.settled_on] ||= 0; h[t.settled_on] += (t.amount / 100.0); h }
      end
      
      #def convert_amount_to_balance(txns)
      #  balance_data = []
      #  balance = 0
      #  txns.keys.sort.each do |date|
      #    amount = txns[date]
      #    balance += amount
      #    balance_data << [date, balance]
      #  end
      #  balance_data
      #end
      #
      #def convert_to_balance_txns(txns)
      #  convert_amount_to_balance(squash_days_and_convert_to_dollars(txns))
      #end
      
      def build_balance_data(all_txns, inner_window, outer_window)
        return [] if all_txns.empty?
        
        txns = squash_days_and_convert_to_dollars(all_txns)
        
        # Fill in the gaps in time.
        # Every day is guaranteed to have *some* data point.
        data = []
        i = 0
        sum = 0
        inner_window.each do |date|
          amount = txns[date]
          if amount
            # Something happened today. Let's show it and update running total.
            sum += amount
            balance = sum
          else
            # No transactions today. Keep same balance.
            balance = sum
          end
          data << [date, balance]
        end
        
        data
      end
      
      def build_income_data(all_txns, inner_window, outer_window, opts)
        opts[:xlabel] ||= lambda {|period_start, period_end| format_date(period_start) + " - " + format_date(period_end) }
        
        txns = build_balance_data(all_txns, inner_window, outer_window)
        #pp :txns => txns
        
        data, xlabels = [], []
        period_start = outer_window.begin
        balance_at_period_start = txns[0][1]
        # Remember that txns is guaranteed to have a data point for each day in the window.
        txns.each_with_index do |(date, balance), i|
          hit_boundary = (date == opts[:get_next_period].call(period_start))
          is_last = (i == txns.size-1)
          is_first = (i == 0)
          if (hit_boundary || is_last) && !is_first
            # Okay, we've crossed a boundary (or hit the end of the dataset).
            # Figure out how much we gained/lost between the start of the last period
            # and today and add the difference to the graph data.
            # Since we've already crossed the boundary we have to pretend like we
            # haven't yet (balance_at_period_start is the balance at the start of the
            # period that just ended).
            diff = balance - balance_at_period_start
            data << diff
            xlabels << opts[:xlabel].call(period_start, opts[:get_next_period].call(period_start))
            # If we're on the last transaction and it's actually the start of another
            # boundary, technically, we haven't made anything this month yet.
            # But we need to record that, otherwise it will never get recorded.
            if is_last && hit_boundary
              data << 0
              xlabels << opts[:xlabel].call(date, opts[:get_next_period].call(date))
            end
            # Since this is actually the start of another boundary, record it
            # so we can refer to it if we hit another boundary.
            period_start = date
            balance_at_period_start = balance
          end
        end
        
        {:data => data, :xlabels => xlabels}
      end
      
    end
  end
end