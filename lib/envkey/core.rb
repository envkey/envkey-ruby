require 'ffi'
require 'dotenv'
require 'json'

module Envkey::Core
  extend FFI::Library
  ffi_lib File.expand_path('../../ext/envkey.so', File.dirname(__FILE__))
  attach_function :EnvJson, [:string], :string

  def self.load_env
    return if ENV['@@ENVKEY_LOADED_ENV']
    Dotenv.load

    if ENV["ENVKEY"]
      json = EnvJson(ENV["ENVKEY"])
      if json.present?
        envs = JSON.parse(json)
        envs.each do |k,v|
          var = k.upcase
          ENV[var] = v unless ENV[var]
        end
        ENV['@@ENVKEY_LOADED_ENV'] = "true"
        puts "ENVKEY: env loaded and decrypted - access via ENV"
      else
        raise "Envkey invalid. Couldn't load env."
      end
    end
  end
end

