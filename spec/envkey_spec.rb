require "spec_helper"
require "envkey/core"

VALID_ENVKEY = "Emzt4BE7C23QtsC7gb1z-3NvfNiG1Boy6XH2o-env-staging.envkey.com"
INVALID_ENVKEY = "Emzt4BE7C23QtsC7gb1z-3NvfNiG1Boy6XH2oinvalid-env-staging.envkey.com"
INVALID_ENVKEY2 = "Emzt4BE7C23QtsC7gb1zinvalid-3NvfNiG1Boy6XH2o-env-staging.envkey.com"

describe Envkey do
  after do
    ENV.delete("ENVKEY")
    ENV.delete("TEST")
    ENV.delete("TEST_2")
  end

  it "has a version number" do
    expect(Envkey::VERSION).not_to be nil
  end

  it "has an envkey-fetch version number" do
    expect(Envkey::ENVKEY_FETCH_VERSION).not_to be nil
  end

  it "loads and decrypts config with a valid ENVKEY" do
    ENV["ENVKEY"] = VALID_ENVKEY
    Envkey::Core.load_env
    expect(ENV["TEST"]).to eq("it")
    expect(ENV["TEST_2"]).to eq("works!")
  end

  it "doesn't overwrite existing ENV vars" do
    ENV["TEST"] = "otherthing"
    ENV["ENVKEY"] = VALID_ENVKEY
    Envkey::Core.load_env
    expect(ENV["TEST"]).to eq("otherthing")
    expect(ENV["TEST_2"]).to eq("works!")
  end

  it "raises an error with an invalid ENVKEY" do
    ENV["ENVKEY"] = INVALID_ENVKEY
    expect { Envkey::Core.load_env }.to raise_error(/ENVKEY invalid/)

    ENV["ENVKEY"] = INVALID_ENVKEY2
    expect { Envkey::Core.load_env }.to raise_error(/ENVKEY invalid/)
  end

  it "raises an error no ENVKEY set" do
    expect { Envkey::Core.load_env }.to raise_error(/ENVKEY missing/)
  end
end
