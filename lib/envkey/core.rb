require 'dotenv'
require 'set'
require 'json'
require 'envkey/fetch'

module Envkey::Core

  def self.load_env overwrite_dotenv_arg=nil, overwrite_envkey_arg=nil
    original_env = ENV.to_h
    dotenv_vars = Dotenv.parse

    overwrite_dotenv_vars = overwrite_dotenv_arg || JSON.parse(ENV["__ENVKEY_DOT_ENV_VARS"] || "[]")
    overwrite_envkey_vars = overwrite_envkey_arg || JSON.parse(ENV["__ENVKEY_VARS"] || "[]")

    updated_dotenv_vars = dotenv_vars.keys.select do |k|
      k != "ENVKEY" && (overwrite_dotenv_vars.include?(k) || original_env[k] == nil)
    end
    updated_dotenv_vars.each do |k|
      ENV[k] = dotenv_vars[k]
    end

    key = (dotenv_vars["ENVKEY"] || ENV["ENVKEY"])

    if (key)
      res = Envkey::Fetch.fetch_env(key)
      if res && res.gsub("\n","").gsub("\r", "") != "" && !res.start_with?("error:")
        envs = JSON.parse(res)
        updated_envkey_vars = []
        envs.each do |k,v|
          var = k.upcase
          if !ENV[var] || overwrite_envkey_vars.include?(var)
            updated_envkey_vars << var
            ENV[var] = v
          end
        end

        ENV["ENVKEY"] = key
        ENV["__ENVKEY_DOT_ENV_VARS"] = updated_dotenv_vars.to_json
        ENV["__ENVKEY_VARS"] = updated_envkey_vars.to_json
        ENV["__ENVKEY_LAST_RUN"] = Time.now.to_f.to_s

        return updated_dotenv_vars, updated_envkey_vars
      elsif res.start_with?("error:")
        STDERR.puts "envkey-fetch " + res
        raise "ENVKEY invalid. Couldn't load vars."
      else
        raise "ENVKEY invalid. Couldn't load vars."
      end
    else
      raise "ENVKEY missing - must be set as an environment variable or in a gitignored .env file in the root of your project. Go to https://www.envkey.com if you don't know what an ENVKEY is."
    end
  end

end

