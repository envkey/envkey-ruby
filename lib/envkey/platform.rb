module Envkey::Platform

  def self.lib_paths
    lib_filenames.map do |fn|
      File.expand_path("../../ext/#{fn}", File.dirname(__FILE__))
    end
  end

  def self.lib_filenames
    is_unix, os, arch, extension = [FFI::Platform.unix?, FFI::Platform::OS, FFI::Platform::ARCH, FFI::Platform::LIBSUFFIX]

    platform_parts =
      if !is_unix
        raise "Envkey currently only supports unix and OSX platforms"
      elsif os == "darwin"
        if arch == "x86_64"
          ["darwin-10.6-amd64"]
        else
          ["darwin-10.6-386"]
        end
      else
        if arch == "x86_64"
          ["linux-amd64", "linux-arm64"]
        elsif arch == "i386"
          ["linux-386"]
        else
          %w(arm64 arm-7 arm-6 arm-5).map {|s| "linux-#{s}"}
        end
      end

    platform_parts.map {|part| "envkey-#{part}.#{extension}"}
  end

end