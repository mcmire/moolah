#require 'capybara'
require 'capybara/dsl' # Needed?

Capybara.app = app
Capybara.javascript_driver = :culerity

Protest::Utils::ColorfulOutput.module_eval do
  def self.colors
    { :passed => "1;32",
      :pending => "1;33",
      :errored => "1;35",
      :failed => "1;31",
      :descriptive => "1;34",
      :story => "2;34"
    }
  end
end

module Protest
  class Reports::Features < Report
    include Utils::Summaries
    include Utils::ColorfulOutput
 
    attr_reader :stream
    attr_accessor :indent_level
 
    def initialize(stream=STDOUT)
      @stream = stream
      @indent_level = 0
    end
    
    def spacing
      ("  " * @indent_level) || ""
    end
    
    # Print the string followed by a newline to whatever IO stream is defined in
    # the method #stream using the correct color depending on the state passed.
    def puts(string=nil, state=:normal)
      if string.nil? # calling IO#puts with nil is not the same as with no args
        stream.puts
      else
        string = "#{spacing}#{string}"
        super(string, state)
      end
    end

    # Print the string to whatever IO stream is defined in the method #stream
    # using the correct color depending on the state passed.
    def print(string=nil, state=:normal)
      if string.nil? # calling IO#puts with nil is not the same as with no args
        stream.print
      else
        string = "#{spacing}#{string}"
        super(string, state)
      end
    end
 
    on :enter do |report, context|
      unless context == Protest::FunctionalTestCase
        desc = context.original_description
        args = []; args << :descriptive if desc =~ /^Feature|Scenario/
        report.puts(desc, *args)# unless context.tests.empty?
        report.indent_level += 1
        if desc =~ /^Feature/
          context.feature_description.each {|line| report.puts(line) }
        end
      end
    end
    
    on :test do |report, test|
      @last_assertions = report.assertions
    end
    
    on :pass do |report, passed_test|
      no_tests = (report.assertions == @last_assertions)
      name = passed_test.test_name
      args = []
      if no_tests
        name += " (no tests!)"
      else
        args << :passed
      end
      report.puts(name, *args)
    end

    on :failure do |report, failed_test|
      position = report.failures_and_errors.index(failed_test) + 1
      report.puts "#{failed_test.test_name} (#{position})", :failed
    end

    on :error do |report, errored_test|
      position = report.failures_and_errors.index(errored_test) + 1
      report.puts "#{errored_test.test_name} (#{position})", :errored
    end

    on :pending do |report, pending_test|
      report.puts "#{pending_test.test_name} (#{pending_test.pending_message})", :pending
    end
 
    on :exit do |report, context|
      unless context == Protest::FunctionalTestCase
        report.indent_level -= 1
        report.puts unless context.tests.empty?
      end
    end
 
    on :end do |report|
      report.summarize_pending_tests
      report.summarize_errors
      report.summarize_test_totals
    end
  end
  add_report :features, Reports::Features
end
  
# Adapted from hashrocket's unencumbered
# http://github.com/hashrocket/unencumbered/blob/master/lib/unencumbered.rb
module Storytime
  module Protest
    def self.extended(klass)
      (class << klass; self; end).class_eval do
        alias_method :feature, :Feature
      end
    end
    
    def Feature(name, &block)
      ::Protest::FunctionalTestCase.describe("Feature: #{name}", &block)
    end
  end
  module TestCase
    def original_description
      @description
    end
  end
  module FunctionalTestCase
    def self.included(klass)
      klass.extend(ClassMethods)
      (class << klass; self; end).class_eval do
        alias_method :Executes, :global_setup
        attr_reader :feature_description
        alias_method :scenario, :Scenario
        alias_method :story, :Story
      end
    end
  
    module ClassMethods
      def Scenario(description, &implementation)
        #describe("Scenario: #{description}", &implementation)
        test("Scenario: #{description}", &implementation)
      end
    
      def Story(desc)
        @feature_description = desc.strip.split(/[ \t]*\n+[ \t]*/)
      end

      %w(Given When Background).each do |method|
        class_eval <<-EOT, __FILE__, __LINE__
          def #{method}(description, &block)
            describe("#{method} \#{description}", &block)
          end
        EOT
      end

      %w(Then And But).each do |method|
        class_eval <<-EOT, __FILE__, __LINE__
          def #{method}(description, &block)
            it("#{method} \#{description}", &block)
          end
        EOT
      end
    end
  end
end

# Copied from cucumber-rails
# http://github.com/aslakhellesoy/cucumber-rails/blob/master/lib/cucumber/web/tableish.rb
module Cucumber
  module Tableish
    # This method returns an Array of Array of String, using CSS3 selectors. 
    # This is particularly handy when using Cucumber's Table#diff! method.
    #
    # The +row_selector+ argument must be a String, and picks out all the rows
    # from the web page's DOM. If the number of cells in each row differs, it
    # will be constrained by (or padded with) the number of cells in the first row
    #
    # The +column_selectors+ argument must be a String or a Proc, picking out
    # cells from each row. If you pass a Proc, it will be yielded an instance
    # of Nokogiri::HTML::Element.
    #
    # == Example with a table
    #
    #   <table id="tools">
    #     <tr>
    #       <th>tool</th>
    #       <th>dude</th>
    #     </tr>
    #     <tr>
    #       <td>webrat</td>
    #       <td>bryan</td>
    #     </tr>
    #     <tr>
    #       <td>cucumber</td>
    #       <td>aslak</td>
    #     </tr>
    #   </table>
    #
    #   t = tableish('table#tools tr', 'td,th')
    #
    # == Example with a dl
    #
    #   <dl id="tools">
    #     <dt>webrat</dt>
    #     <dd>bryan</dd>
    #     <dt>cucumber</dt>
    #     <dd>aslak</dd>
    #   </dl>
    #
    #   t = tableish('dl#tools dt', lambda{|dt| [dt, dt.next.next]})
    #
    def tableish(row_selector, column_selectors)
      html = defined?(Capybara) ? body : response_body
      _tableish(html, row_selector, column_selectors)
    end

    def _tableish(html, row_selector, column_selectors) #:nodoc
      doc = Nokogiri::HTML(html)
      column_count = nil
      doc.search(row_selector).map do |row|
        cells = case(column_selectors)
        when String
          row.search(column_selectors)
        when Proc
          column_selectors.call(row)
        end
        column_count ||= cells.length
        (0...column_count).map do |n|
          cell = cells[n]
          case(cell)
            when String then cell.strip
            when nil then ''
            else cell.text.strip
          end
        end
      end
    end
  end
end

module Protest
  class TestCase
    extend Storytime::TestCase
  end

  class FunctionalTestCase < TestCase
    include Storytime::FunctionalTestCase
    include Capybara
    include Cucumber::Tableish
  end
  
  extend Storytime::Protest
end

# Can we can control this somehow?
Protest.report_with(:features)