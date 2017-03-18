require "envkey/core"

module Envkey
  class Railtie < Rails::Railtie

    config.before_configuration do
      begin
        require "spring/commands"
        ts = Time.now
        overload_dotenv_vars = Envkey::Core.load_env
        Spring.after_fork do
          Envkey::Core.load_env(ts, overload_dotenv_vars)
        end

      rescue LoadError
        Envkey::Core.load_env
      end
    end
  end
end