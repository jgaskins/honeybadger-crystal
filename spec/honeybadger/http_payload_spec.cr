require "../spec_helper"
require "file_utils"

describe Honeybadger::HttpPayload do
  describe "compile time data collection" do
    it "populates the compile_dir" do
      Honeybadger::HttpPayload::COMPILE_DIR.should eq FileUtils.pwd
    end

    it "populates the hostname" do
      Honeybadger::HttpPayload::HOSTNAME.should_not be ""
    end

    it "populates the git_revision" do
      Honeybadger::HttpPayload::GIT_REVISION.should_not be ""
    end
  end

  describe "to_json" do
    it "embeds the request path" do
      expected_request_path = "/honeybadger/crystal"

      context = MockHttp.with_request resource: expected_request_path
      payload = Honeybadger::HttpPayload.new Exception.new, context
      JSON.parse(payload.to_json)["request"]["url"].as_s.should eq expected_request_path
    end

    it "embeds request params" do
      params = {parameter1: "value1", parameter2: "value2"}
      context = MockHttp.new.context(
        request: MockHttp.build_form_request params: params
      )

      payload = Honeybadger::HttpPayload.new Exception.new, context
      results = JSON.parse(payload.to_json)

      params.each do |key, value|
        results["request"]["params"].as_h[key.to_s]?.should eq value
      end
    end

    it "embeds multipart form params" do
      params = {parameter1: "value1", parameter2: "value2"}
      context = MockHttp.new.context(
        request: MockHttp.build_multipart_request params: params
      )

      payload = Honeybadger::HttpPayload.new Exception.new, context
      results = JSON.parse(payload.to_json)

      params.each do |key, value|
        results["request"]["params"].as_h[key.to_s]?.should eq value
      end
    end

    it "embeds json form params" do
      params = {parameter1: "value1", parameter2: "value2"}
      context = MockHttp.new.context(
        request: MockHttp.build_json_request params: params
      )

      payload = Honeybadger::HttpPayload.new Exception.new, context
      results = JSON.parse(payload.to_json)

      params.each do |key, value|
        results["request"]["params"].as_h[key.to_s]?.should eq value
      end
    end
  end
end