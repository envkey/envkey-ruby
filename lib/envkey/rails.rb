require "envkey/core"

module Envkey
  class Railtie < Rails::Railtie
    config.before_configuration do
      Rails.logger.debug "config.before_configuration"
      begin
        require "spring/commands"
        overwrite_dotenv, ovewrite_envkey = Envkey::Core.load_env
        Spring.after_fork do
          Envkey::Core.load_env(overwrite_dotenv, overwrite_envkey)
        end
      rescue LoadError
        Envkey::Core.load_env
      end
    end
  end
end