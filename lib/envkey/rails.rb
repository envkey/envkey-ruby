require "envkey/core"

module Envkey
  class Railtie < Rails::Railtie
    config.before_configuration do
      begin
        require "spring/commands"
        Envkey::Core.load_env
        Spring.after_fork do
          Envkey::Core.load_env
        end
      rescue LoadError
        Envkey::Core.load_env
      end
    end
  end
end
