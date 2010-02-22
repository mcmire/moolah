require 'yaml'

# We can't subclass our application since for some reason that will prematurely
# initialize some of the application-specific stuff (such as routing)
class Padrino::Application
  def self.settings(env = PADRINO_ENV)
    @settings ||= YAML.load_file(Padrino.root("config/settings.yml"))
    @settings[env.to_s]
  end
  def self.common_settings
    settings("common")
  end
end