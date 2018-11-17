# frozen_string_literal: true

require 'test_helper'
require 'pry'

class ChangelogsTest < Minitest::Test
  CURRENT_PIJI_VERSION = "1.2.0"
  PREVIOUS_PIJI_VERSION = "1.1.0"
  EXAMPLE_CHANGELOG = "this is the changelog\n version #{CURRENT_PIJI_VERSION} foo\n version #{PREVIOUS_PIJI_VERSION} bar"
  
  def current_dependencies
    {
      "peiji-san" => Bundler::Dependency.new("peiji-san", ">= 0"),
      "rake" => Bundler::Dependency.new("rake", ">= 0"),
    }
  end
=begin
  def current_lockfile_contents
    strip_whitespace(<<-L) }
    GIT
      remote: https://github.com/alloy/peiji-san.git
      revision: eca485d8dc95f12aaec1a434b49d295c7e91844b
      specs:
        peiji-san (1.2.0)

    GEM
      remote: https://rubygems.org/
      specs:
        rake (10.3.2)

    PLATFORMS
      ruby

    DEPENDENCIES
      peiji-san!
      rake

    RUBY VERSION
       ruby 2.1.3p242

    BUNDLED WITH
       1.12.0.rc.2
L
  end
=end

  def current_specs
    [
      Bundler::LazySpecification.new("peiji-san", v(CURRENT_PIJI_VERSION), rb),
      Bundler::LazySpecification.new("rake", v("10.3.2"), rb),
    ]
  end
  def previous_specs
    [
      Bundler::LazySpecification.new("peiji-san", v(PREVIOUS_PIJI_VERSION), rb),
      Bundler::LazySpecification.new("rake", v("10.3.2"), rb),
    ]
  end

  #TODO: a double will be useful if we ever incorporate curated summaries in the bundler-changelogs repo
=begin
  class ChangelogsDouble
    def search
      @searched = true
    end

    def searched?
      @searched
    end
  end
=end

  def test_version
    refute_nil ::Bundler::Changelogs::VERSION
  end
  
  def test_install_generates_git_managed_lockfile
    skip "TODO: test lifecycle event"
  end

  def test_basic
    command = Bundler::Changelogs::Command.new
    with_dummy_dependencies_and_specs(command) do
      Bundler.ui.stub(:info,->(msg){ @info = msg }) do 
        command.stub(:open, ->(path) { EXAMPLE_CHANGELOG }) do
          command.exec(nil, [])
        end
      end
    end

    assert @info.include?(CURRENT_PIJI_VERSION), "Should show current version changelog messages"
    assert !@info.include?(PREVIOUS_PIJI_VERSION), "Should NOT show previous version changelog messages"
  end

  private
  def v(version)
    Gem::Version.new(version)
  end

  def rb 
    #irrelevant
    Gem::Platform.new("x86_64-darwin-15")
  end
  
  class FakeSpecification
    def metadata
      {'changelog_uri'=>'http://some.url/path/to/changelog.md'}
    end
  end
  
  def with_dummy_dependencies_and_specs(command)
    command.stub(:materialize,->(spec){ spec.instance_variable_set(:@specification,FakeSpecification.new); nil }) do
      command.stub(:current_lockfile_parsed,->(*){ OpenStruct.new(specs: current_specs, dependencies: current_dependencies) }) do
        command.stub(:previous_lockfile_parsed,->(*){ OpenStruct.new(specs: previous_specs) }) do
          yield 
        end
      end
    end
  end

end
