require "envkey/version"

begin
  require "spring/commands"
  Spring.after_fork do
    require "envkey/core"
    Envkey::Core.load_env
  end
rescue LoadError
  require "envkey/core"
  Envkey::Core.load_env
end



