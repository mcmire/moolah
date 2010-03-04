#require 'capybara'
require 'capybara/dsl' # Needed?

Capybara.app = app
Capybara.app_host = "http://localhost:5151"
Capybara.javascript_driver = :culerity
Capybara.default_selector = :css
Capybara.debug = true

Capybara::Driver::Celerity.class_eval do
  # Override this so that the firefox3 browser is used,
  # and we make sure ajax is synchronized
  def browser
    unless @_browser
      @_browser = ::Culerity::RemoteBrowserProxy.new self.class.server, {:browser => :firefox3, :log_level => :fine, :javascript_exceptions => true, :resynchronize => true}
      at_exit do
        @_browser.exit
      end
    end
    @_browser
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

# The 'feature' stuff was adapted from hashrocket's unencumbered
# (http://github.com/hashrocket/unencumbered/blob/master/lib/unencumbered.rb)
# which came from http://blog.voxdolo.me/gibbon.html
# and this is also kind of like foca's storyteller
module Protest
  class << self
    def Feature(name, &block)
      IntegrationTestCase.describe("Feature: #{name}", &block)
    end
    alias_method :feature, :Feature
    
    def js_feature(name, &block)
      JavascriptIntegrationTestCase.describe("Feature: #{name} (via Javascript)", &block)
    end
  end
  
  class TestCase
    def self.original_description
      @description
    end
  end

  class IntegrationTestCase < TestCase
    class << self
      def Scenario(description, &block)
        #describe("Scenario: #{description}", &block)
        test("Scenario: #{description}", &block)
      end
    
      def Story(desc)
        @feature_description = desc.strip.split(/[ \t]*\n+[ \t]*/)
      end
      
      #def javascript_scenarios(&block)
      #  # Hmm, wish there was a better way of doing this...
      #  description = "via Javascript"
      #  subclass = Class.new(self)
      #  subclass.extend(JavascriptIntegrationTestCase)
      #  subclass.class_eval(&block) if block
      #  subclass.description = description
      #  const_set(sanitize_description(description), subclass)
      #end

      #%w(Given When Background).each do |method|
      #  class_eval <<-EOT, __FILE__, __LINE__
      #    def #{method}(description, &block)
      #      describe("#{method} \#{description}", &block)
      #    end
      #  EOT
      #end
      #
      #%w(Then And But).each do |method|
      #  class_eval <<-EOT, __FILE__, __LINE__
      #    def #{method}(description, &block)
      #      it("#{method} \#{description}", &block)
      #    end
      #  EOT
      #end
      
      #alias_method :Executes, :global_setup
      attr_reader :feature_description
      alias_method :scenario, :Scenario
      alias_method :story, :Story
    end
    
    include Capybara
    include Cucumber::Tableish
  end
  
  module JavascriptIntegrationTestCaseMixin
    def self.included(includee)
      includee.class_eval do
        global_setup do
          Capybara.current_driver = Capybara.javascript_driver
        end
        global_teardown do
          Capybara.use_default_driver
        end
      end
    end
    
    def browser
      page.driver.browser
    end
  end
  
  class JavascriptIntegrationTestCase < IntegrationTestCase
    include JavascriptIntegrationTestCaseMixin
  end
  
  module Utils
    module ColorfulOutput
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
  end
  
  # This is like the Documentation report
  # except that the full name of a nested context is not printed
  # and we indent the tests and sub-contexts
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
    
    # Add indentation to color output
    def puts(string=nil, state=:normal)
      if string.nil? # calling IO#puts with nil is not the same as with no args
        stream.puts
      else
        string = "#{spacing}#{string}"
        super(string, state)
      end
    end

    # Add indentation to color output
    def print(string=nil, state=:normal)
      if string.nil? # calling IO#puts with nil is not the same as with no args
        stream.print
      else
        string = "#{spacing}#{string}"
        super(string, state)
      end
    end
 
    # Output a feature, story, scenario, or context
    # Features aren't indented, the story and scenario are indented once,
    # and contexts are indented once further
    on :enter do |report, context|
      unless context == Protest::IntegrationTestCase or context == JavascriptIntegrationTestCase
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
    
    # Little tweak: Let the user know if there weren't any assertions made in this test
    on :pass do |report, passed_test|
      no_tests = (report.assertions == @last_assertions)
      name = passed_test.test_name
      args = []
      if no_tests
        name += "\033[0;31m (no assertions!)\033[0m"
      else
        args << :passed
      end
      report.puts(name, *args)
    end

    # Same as Documentation
    on :failure do |report, failed_test|
      position = report.failures_and_errors.index(failed_test) + 1
      report.puts "#{failed_test.test_name} (#{position})", :failed
    end

    # Same as Documentation
    on :error do |report, errored_test|
      position = report.failures_and_errors.index(errored_test) + 1
      report.puts "#{errored_test.test_name} (#{position})", :errored
    end

    # Same as Documentation
    on :pending do |report, pending_test|
      report.puts "#{pending_test.test_name} (#{pending_test.pending_message})", :pending
    end
 
    # Return the indentation level back what it was before the feature, story, scenario, or context
    on :exit do |report, context|
      unless context == Protest::IntegrationTestCase or context == JavascriptIntegrationTestCase
        report.indent_level -= 1
        report.puts unless context.tests.empty?
      end
    end
 
    # Same as Documentation
    on :end do |report|
      report.summarize_pending_tests
      report.summarize_errors
      report.summarize_test_totals
    end
  end
  add_report :features, Reports::Features
end