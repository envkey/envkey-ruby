require 'envkey/platform'

module Envkey::Fetch

  def self.fetch_env key
    fetch_env_path = Envkey::Platform.fetch_env_path
    `#{fetch_env_path} #{key}#{is_dev ? ' --cache' : ''} --client-name envkey-ruby --client-version #{Envkey::VERSION}`
  end

  def self.is_dev
    dev_vals = %w(development test)
    dev_vals.include?(ENV["RAILS_ENV"]) ||
      dev_vals.include?(ENV["RACK_ENV"]) ||
      (ENV["RAILS_ENV"].nil? && ENV["RACK_ENV"].nil? && File.exist?(".env"))
  end

end