require 'dotenv'
require 'set'
require 'json'
require 'envkey/fetch'

module Envkey::Core
  def self.envkey_original_env
    ENV["ENVKEY_ORIGINAL_ENV"] ||= ENV.to_json
    JSON.parse(ENV["ENVKEY_ORIGINAL_ENV"]).to_h
  end

  def self.fetch
    if !ENV["ENVKEY"]
      raise "ENVKEY missing - must be set as an environment variable or in a gitignored .env file in the root of your project. Go to https://www.envkey.com if you don't know what an ENVKEY is."
    end

    res = Envkey::Fetch.fetch_env(ENV["ENVKEY"])
    if res && res.gsub("\n","").gsub("\r", "") != "" && !res.start_with?("error:")
      return JSON.parse(res)
    elsif res.start_with?("error:")
      STDERR.puts "envkey-fetch " + res
      raise "ENVKEY invalid. Couldn't load vars."
    else
      raise "ENVKEY invalid. Couldn't load vars."
    end
  end

  def self.load_env
    original_env = envkey_original_env

    envs = fetch
    envs.each do |k,v|
      var = k.upcase
      ENV[var] = v if !original_env[var]
    end

    dotenv_vars = Dotenv.load
    dotenv_vars.each do |var|
      ENV[var] = dotenv_vars[var] if !original_env[var]
    end
  end
end

