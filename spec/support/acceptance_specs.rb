require 'capybara/dsl'

Capybara.app = Moolah.new
Capybara.app_host = "http://localhost:5151"
Capybara.javascript_driver = :culerity
Capybara.run_server = false
Capybara.default_selector = :css
Capybara.debug = true

RUN_JAVASCRIPT_TESTS = 
  if File.exists?("tmp/acceptance_spec.opts")
    !!YAML.load_file("tmp/acceptance_spec.opts")[:javascript]
  else
    false
  end

module Capybara
  class Server
    # Added: extracted from #is_port_open? so that the Celerity driver can access it
    def self.reachable?(host, port)
      Timeout::timeout(1) do
        begin
          s = TCPSocket.new(host, port)
          s.close
          return true
        rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
          return false
        end
      end
    rescue Timeout::Error
      return false
    end
    
    # Patched: Extracted to .is_port_open?
    def is_port_open?(tested_port)
      self.class.reachable?(host, tested_port)
    end
  end
  
  module Driver
    class Celerity
      # Patched: Check that the app_host is reachable, if that specified
      def initialize(app)
        @app = app
        @rack_server = Capybara::Server.new(@app)
        if Capybara.run_server
          @rack_server.boot
        elsif Capybara.app_host
          host, port = Capybara.app_host.split("//")[1].split(":")
          msg = "It doesn't look like your app at #{Capybara.app_host} is reachable. Should you have started it beforehand?"
          Capybara::Server.reachable?(host, port) or raise(msg)
        else
          # we know by this point the rack server is up
          # so don't worry about checking that
        end
      end
  
      # Patched: Use firefox3 instead of firefox, make sure ajax is synchronized
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
  end
end

# Copied from cucumber-rails
# http://github.com/aslakhellesoy/cucumber-rails/blob/master/lib/cucumber/web/tableish.rb
module Cucumber
  module Tableish
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

# The code here is adapted from unencumbered [1] and steak [2].
# Coincidentally this is also like storyteller [3].
# Next up: creating something like stories? [4].
#
# [1]: http://github.com/hashrocket/unencumbered/blob/master/lib/unencumbered.rb
# [2]: http://github.com/cavalle/steak
# [3]: http://github.com/foca/storyteller
# [4]: http://github.com/citrusbyte/stories

module Spec::DSL::Main
  alias_method :feature, :describe
end

class AcceptanceExampleGroup < Spec::Example::ExampleGroup
  include Capybara
  include Cucumber::Tableish

  module JavascriptExampleMethods
    def browser
      page.driver.browser
    end
  end

  class << self
    def scenario(description, &block)
      it("Scenario: #{description}", &block)
    end
  
    def story(description)
      description = description.strip.split(/[ \t]*\n+[ \t]*/).map {|line| "  #{line}\n" }.join
      #@feature_description = description
      @description_args.push("\n#{description}\n")
    end
    
    def under_javascript(&block)
      return unless RUN_JAVASCRIPT_TESTS
      describe "(under Javascript)" do
        # Copied from Capybara's Cucumber mixin
        before do
          Capybara.current_driver = Capybara.javascript_driver
        end
        after do
          Capybara.use_default_driver
        end
        after :all do
          Capybara.reset_sessions!
        end
        include JavascriptExampleMethods
        instance_eval(&block)
      end
    end
  end
  
  def current_path
    URI.parse(current_url).path
  end

  # Copied from Steak
  def method_missing(sym, *args, &block)
    return Spec::Matchers::Be.new(sym, *args)  if sym.to_s =~ /^be_/
    return Spec::Matchers::Has.new(sym, *args) if sym.to_s =~ /^have_/
    super
  end
  
  Spec::Example::ExampleGroupFactory.register(:acceptance, self)
end