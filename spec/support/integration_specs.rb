if defined?(Rails)
  require 'capybara/rails'
else
  require 'capybara/dsl'
end
require 'capybara/envjs'

Capybara.app = Moolah.new
#Capybara.app_host = "http://localhost:5151"
Capybara.javascript_driver = :envjs
#Capybara.default_driver = :rack_test
Capybara.run_server = false
Capybara.default_selector = :css
Capybara.debug = true

module Capybara
  module SaveAndOpenPage
    def self.save_and_open_page(html)
      # PATCH: Put the file in a temp directory so we don't pollute our working directory
      name="#{Dir.tmpdir}/capybara-#{Time.new.strftime("%Y%m%d%H%M%S")}.html"
  
      FileUtils.touch(name) unless File.exist?(name)
  
      tempfile = File.new(name,'w')
      tempfile.write(rewrite_css_and_image_references(html))
      tempfile.close
  
      open_in_browser(tempfile.path)
    end

    def self.open_in_browser(path)
      # Use Chrome if that's open, otherwise use whichever browser Launchy picks
      if `ps aux | grep 'Google Chrome' | grep -v 'grep Google Chrome'`.blank?
        begin
          require "launchy"
          Launchy::Browser.run(path)
        rescue LoadError
          warn "Sorry, you need to install launchy to open pages: `gem install launchy`"
        end
      else
        `open -a '/Applications/Google Chrome.app' '#{path}'`
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
  def feature(description, &block)
    # the caller here is essential or else the --line option to `spec` doesn't work
    describe("Feature: #{description}", :type => :integration, :location => caller(0)[1], &block)
  end
end

module ExampleGroupHierarchyExtensions
  def nested_descriptions_with_stories
    @nested_descriptions_with_stories ||= collect {|group|
      nd = nested_description_from(group)
      (nd == "") ? nil : [nd, group.respond_to?(:story) ? group.story : nil]
    }.compact
  end
end
Spec::Example::ExampleGroupHierarchy.send(:include, ExampleGroupHierarchyExtensions)

Spec::Example::ExampleGroupProxy.class_eval do
  def initialize_with_stories(example_group)
    initialize_without_stories(example_group)
    @nested_descriptions_with_stories = example_group.nested_descriptions_with_stories
  end
  alias_method_chain :initialize, :stories
  attr_reader :nested_descriptions_with_stories
end

module ExampleGroupExtensions
  def nested_descriptions_with_stories
    example_group_hierarchy.nested_descriptions_with_stories
  end
end
Spec::Example::ExampleGroup.extend(ExampleGroupExtensions)

module IntegrationExampleMethods
  def current_path
    uri = URI.parse(current_url)
    path = uri.path
    path += "?" + uri.query if uri.query
    path
  end
  
  #def html
  #  page.driver.html
  #end
  
  def body_as_text
    page.driver.html.text
  end
  
  # Override wait_until so that instead of waiting for the specified amount of time
  # and then failing if the block fails, retries the block every 0.5 for the
  # specified amount of time. This made more sense to me.
  def wait_until(timeout=10, &block)
    time = Time.now
    success = false
    until success
      if (Time.now - time) >= timeout
        raise "Waited for #{timeout} seconds, but block never returned true"
      end
      sleep 0.5
      success = yield
    end
  end

  # Copied from Steak
  def method_missing(sym, *args, &block)
    return Spec::Matchers::Be.new(sym, *args)  if sym.to_s =~ /^be_/
    return Spec::Matchers::Has.new(sym, *args) if sym.to_s =~ /^have_/
    super
  end
end

module JavascriptExampleMethods
  def browser
    page.driver.browser
  end
  
  def body_as_text
    browser.document.as_text
  end
  
  #def html
  #  @html ||= Nokogiri::HTML(body)
  #end
  
  # Override this to use Celerity's wait_until since Capybara doesn't seem to do this already
  # XXX: Necessary with envjs?
  def wait_until(timeout, &block)
    browser.wait_until(timeout, &block)
  end
  
  def accepting_confirm_boxes(&block)
    page.evaluate_script('window.__oldConfirm = window.confirm; window.confirm = function() { return true; }')
    yield
    page.evaluate_script('window.confirm = window.__oldConfirm')
  end
  
  def rejecting_confirm_boxes
    page.evaluate_script('window.__oldConfirm = window.confirm; window.confirm = function() { return false; }')
    yield
    page.evaluate_script('window.confirm = window.__oldConfirm')
  end
end

module IntegrationExampleGroupMethods
  def self.extended(extender)
    extender.after do
      # Reset sessions so that things like session[:whatever] do not carry over into other tests
      Capybara.reset_sessions!
    end
  end
  
  def background(&block)
    before(:each, &block)
  end
  
  def scenario(description, location=nil, &block)
    # the caller here is essential or else the --line option to `spec` doesn't work
    it("Scenario: #{description}", {}, (location || caller(0)[1]), &block)
  end
  
  def xscenario(description)
    xit("Scenario: #{description}")
  end
  
  def broken_scenario(description, reason="Scenario needs to be fixed", location=nil, &block)
    # the caller here is essential or else the --line option to `spec` doesn't work
    it("Scenario: #{description}", {}, (location || caller(0)[1])) do
      pending(reason) { yield }
    end
  end
  
  def pending_scenario(description, reason="Not Yet Implemented", location=nil, &block)
    # the caller here is essential or else the --line option to `spec` doesn't work
    it("Scenario: #{description}", {}, (location || caller(0)[1])) do
      pending(reason)
      yield
    end
  end

  def story(story=nil)
    @story = story.strip.split(/[ \t]*\n+[ \t]*/) if story
    @story
  end
  alias :narrative :story
  
  def javascript(&block)
    run_javascript_tests = File.exists?("tmp/integration_spec.opts") && !!YAML.load_file("tmp/integration_spec.opts")[:javascript]
    return unless run_javascript_tests
    describe "(under Javascript)" do
      # Copied from Capybara's Cucumber mixin
      before :all do
        Capybara.current_driver = Capybara.javascript_driver
      end
      
      # Basically what we're doing here is telling RSpec to truncate/seed the database
      # BEFORE any before(:each) blocks in the superclass are executed
      #proc = Proc.new {
      #  Moolah.plow_database(:all => true, :level => :info)
      #  Moolah.seed_database(:level => :info)
      #}
      #example_group_hierarchy.before_each_parts.unshift(proc)
      
      after :all do
        #page.driver.clear_browser
        Capybara.use_default_driver
      end
      include JavascriptExampleMethods
      instance_eval(&block)
    end
  end
  
  # This is now a no-op
  #def javascript(&block)
  #  instance_eval(&block)
  #end
end

if defined?(Spec::Rails)
  # Rails-based apps
  class IntegrationExampleGroup < Spec::Rails::Example::IntegrationExampleGroup
    include ActionController::RecordIdentifier
  end
else
  # Rack-based apps (Sinatra, Padrino, etc.)
  class IntegrationExampleGroup < Spec::Example::ExampleGroup
  end
end
IntegrationExampleGroup.class_eval do
  include Capybara
  include Cucumber::Tableish  
  include IntegrationExampleMethods
  #include JavascriptExampleMethods
  extend IntegrationExampleGroupMethods
end
Spec::Example::ExampleGroupFactory.register(:integration, IntegrationExampleGroup)