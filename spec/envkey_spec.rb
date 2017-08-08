require "spec_helper"
require "envkey/core"

describe Envkey do
  after do
    ENV.delete("ENVKEY")
    ENV.delete("GO_TEST")
    ENV.delete("GO_TEST_2")
  end

  it "has a version number" do
    expect(Envkey::VERSION).not_to be nil
  end

  it "loads and decrypts config with a valid Enkey" do
    ENV["ENVKEY"] = "zvHpsWR9Fx44xYP1MM7D-4kfqz28Sr6eiD9G3-localhost:8090"
    Envkey::Core.load_env
    expect(ENV["GO_TEST"]).to eq("it")
    expect(ENV["GO_TEST_2"]).to eq("works!")
  end

  it "raises an error with an invalid Envkey" do
    ENV["ENVKEY"] = "zvHpsWR9Fx44xYP1MM7D-4kfqz28Sr6eiD9Ginvalid-localhost:8090"
    expect { Envkey::Core.load_env }.to raise_error(/Envkey invalid/)
  end

  it "does nothing with no Envkey set" do
    Envkey::Core.load_env
    expect(ENV["GO_TEST"]).to be nil
  end
end
