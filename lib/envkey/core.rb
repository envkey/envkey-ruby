require 'ffi'
require 'dotenv'
require 'json'
require 'set'

module Envkey::Core
  extend FFI::Library

  def self.load_env spring_pre_fork_ts=nil, overload_dotenv_vars=Set.new([])
    original_env = ENV.to_h
    dotenv_vars = Dotenv.load
    updated_vars = dotenv_vars.keys.select do |k|
      overload_dotenv_vars.include?(k) || original_env[k] == nil
    end
    overload_dotenv_vars.each do |k|
      ENV[k] = dotenv_vars[k]
    end

    if (key = ENV["ENVKEY"])
      reader, writer = IO.pipe

      fork do
        reader.close

        ffi_lib File.expand_path('../../ext/envkey.so', File.dirname(__FILE__))
        attach_function :EnvJson, [:pointer], :string

        json = EnvJson(FFI::MemoryPointer.from_string(key))
        writer.puts json
      end

      writer.close
      while json = reader.gets
        if json && json.gsub("\n","").gsub("\r", "") != ""
          envs = JSON.parse(json)
          envs.each do |k,v|
            var = k.upcase
            ENV[var] = v unless ENV[var]
          end

          # avoid printing success message twice in quick succession when using spring
          if !spring_pre_fork_ts || (Time.now - spring_pre_fork_ts) > 3
            puts "ENVKEY: vars loaded and decrypted - access with ENV['YOUR_VAR_NAME']"
          end
          return Set.new(updated_vars)
        else
          raise "Envkey invalid. Couldn't load env."
        end
      end
    end
  end
end

