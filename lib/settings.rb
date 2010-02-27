require 'yaml'

# We can't subclass our application since for some reason that will prematurely
# initialize some of the application-specific stuff (such as routing)
class Padrino::Application
  class << self
    # adapted from http://sickpea.com/2009/6/rails-app-configuration-in-10-lines
    def settings(env = PADRINO_ENV)
      @settings ||= YAML.load(ERB.new(File.read(Padrino.root("config/settings.yml"))).result)
      HashWithIndifferentAccess.new(@settings[env.to_s]).freeze
    end
    alias_method :config, :settings
    def [](key)
      settings[key]
    end
    def common_settings
      settings("common")
    end
    alias_method :common_config, :common_settings
  end
end