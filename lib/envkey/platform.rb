module Envkey::Platform
  # Normalize the platform OS
  OS = case os = RbConfig::CONFIG['host_os'].downcase
  when /linux/
    "linux"
  when /darwin/
    "darwin"
  when /freebsd/
    "freebsd"
  when /netbsd/
    "netbsd"
  when /openbsd/
    "openbsd"
  when /sunos|solaris/
    "solaris"
  when /mingw|mswin/
    "windows"
  else
    os
  end

  # Normalize the platform CPU
  ARCH = case cpu = RbConfig::CONFIG['host_cpu'].downcase
  when /amd64|x86_64/
    "x86_64"
  when /i?86|x86|i86pc/
    "x86"
  when /ppc|powerpc/
    "powerpc"
  when /^arm/
    "arm"
  else
    cpu
  end

  def self.fetch_env_path
    File.expand_path("../../ext/#{lib_filename}", File.dirname(__FILE__))
  end

  def self.lib_filename
    platform_part = case OS
      when "darwin", "linux", "windows", "freebsd", "netbsd", "openbsd"
        OS
      else
        "linux"
      end

    arch_part = case ARCH
      when "x86_64"
        "amd64"
      when "x86", "powerpc"
        "386"
      when "arm"
        "arm"
      else
        "386"
      end

    ext = platform_part == "windows" ? ".exe" : ""

    ["envkey-fetch", platform_part, arch_part + ext].join("-")
  end

end