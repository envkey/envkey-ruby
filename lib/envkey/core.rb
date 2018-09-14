require 'dotenv'
require 'set'
require 'json'
require 'envkey/fetch'

module Envkey::Core

  def self.load_env spring_pre_fork_ts=nil,
                    overload_dotenv_vars=[],
                    overload_envkey_vars=[]
    original_env = ENV.to_h
    dotenv_vars = Dotenv.load
    updated_dotenv_vars = dotenv_vars.keys.select do |k|
      overload_dotenv_vars.include?(k) || original_env[k] == nil
    end
    overload_dotenv_vars.each do |k|
      ENV[k] = dotenv_vars[k]
    end

    if (key = ENV["ENVKEY"])
      res = Envkey::Fetch.fetch_env(key)
      if res && res.gsub("\n","").gsub("\r", "") != "" && !res.start_with?("error:")
        envs = JSON.parse(res)
        updated_envkey_vars = []
        envs.each do |k,v|
          var = k.upcase
          if !ENV[var] || overload_envkey_vars.include?(var)
            updated_envkey_vars << var
            ENV[var] = v
          end
        end

        return [Set.new(updated_dotenv_vars), Set.new(updated_envkey_vars)]
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

