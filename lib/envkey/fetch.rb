require 'json'
require 'envkey/platform'

module Envkey::Fetch

  def self.fetch_env key
    fetch_env_path = Envkey::Platform.fetch_env_path
    `#{fetch_env_path} #{key} --cache`
  end

end