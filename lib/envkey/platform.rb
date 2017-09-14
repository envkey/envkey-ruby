module Envkey::Platform
  # Normalize the platform OS
  OS = case os = RbConfig::CONFIG['host_os'].downcase
  when /linux/
    "linux"
  when /darwin/
    "darwin"
  when /bsd/
    "freebsd"
  when /mingw|mswin/
    "windows"
  else
    "linux"
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

  def self.platform_part
    case OS
      when "darwin", "linux", "windows", "freebsd"
        OS
      else
        "linux"
      end
  end

  def self.arch_part
    ARCH == "x86_64" ? "amd64" : "386"
  end

  def self.ext
    platform_part == "windows" ? ".exe" : ""
  end

  def self.fetch_env_path
    File.expand_path("../../ext/#{lib_file_dir}/envkey-fetch#{ext}", File.dirname(__FILE__))
  end

  def self.lib_file_dir
    ["envkey-fetch", Envkey::ENVKEY_FETCH_VERSION.to_s, platform_part, arch_part].join("_")
  end

end