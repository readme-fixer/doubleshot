#!/usr/bin/env jruby

require_relative "helper.rb"

describe Doubleshot do

  describe "classpath_cache" do
    it "must be a Pathname" do
      Doubleshot.new.classpath_cache.must_be_kind_of Pathname
    end
  end

  describe "classpath" do
    before do
      @doubleshot = Doubleshot.new do |config|
        config.jar "ch.qos.logback:logback-core:1.0.6"
      end
      Helper::tmp do |tmp|
        @doubleshot.path = tmp + "Doubleshot.test"
      end
    end

    it "must be empty on instantiation" do
      @doubleshot.classpath.must_be_empty
    end

    it "won't be empty after setup (if you have JAR dependencies)" do
      @doubleshot.setup!
      @doubleshot.classpath.wont_be_empty
    end
  end

  describe "configuration" do
    it "must pass a Configuration object to the block" do
      called = false
      Doubleshot.new do |config|
        called = true
        config.must_be_kind_of Doubleshot::Configuration
      end
      assert called, "block not called"
    end
  end

  it "must generate a valid gemspec" do
    gemspec = Doubleshot.new do |config|
      config.gemspec do |spec|
        spec.name          = "doubleshot"
        spec.summary       = "Build, Dependencies and Testing all in one!"
        spec.description   = "Description"
        spec.author        = "Sam Smoot"
        spec.homepage      = "https://github.com/sam/doubleshot"
        spec.email         = "ssmoot@gmail.com"
        spec.version       = "1.0"
        spec.license       = "MIT-LICENSE"
        spec.executables   = [ "doubleshot" ]
      end
    end.build_gemspec

    eval(gemspec).validate
  end

  describe "current" do
    it "must be a kind of Doubleshot" do
      Doubleshot::current.must_be_kind_of Doubleshot
    end

    it "must read a sampling of values correctly" do
      config = Doubleshot::current.config
      config.gemspec.name.must_equal "doubleshot"
      config.source.ruby.to_s.must_equal "lib"
      config.target.to_s.must_equal "target"
    end

    describe "lockfile" do
      it "must return a Lockfile instance" do
        Doubleshot::current.lockfile.must_be_kind_of Doubleshot::Lockfile
      end
    end
  end



end
