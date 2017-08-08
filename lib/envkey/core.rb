require 'dotenv'
require 'set'
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
      json = Envkey::Fetch.fetch_env(key)

      if json && json.gsub("\n","").gsub("\r", "") != ""
        envs = JSON.parse(json)
        updated_envkey_vars = []
        envs.each do |k,v|
          var = k.upcase
          if !ENV[var] || overload_envkey_vars.include?(var)
            updated_envkey_vars << var
            ENV[var] = v
          end
        end

        # avoid printing success message twice in quick succession when using spring
        if !spring_pre_fork_ts || (Time.now - spring_pre_fork_ts) > 3
          puts "ENVKEY: vars loaded and decrypted - access with ENV['YOUR_VAR_NAME']"
        end
        return [Set.new(updated_dotenv_vars), Set.new(updated_envkey_vars)]
      else
        raise "Envkey invalid. Couldn't load vars."
      end
    end
  end

end

