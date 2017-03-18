require "envkey/version"

if defined?(Rails)
  require "envkey/rails"
else
  require "envkey/core"
  Envkey::Core.load_env
end



