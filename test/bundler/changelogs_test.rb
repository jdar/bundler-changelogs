# frozen_string_literal: true

require 'test_helper'

class ChangelogsTest < Minitest::Test
  class ChangelogsDouble
    def search
      @searched = true
    end

    def searched?
      @searched
    end
  end

  def test_version
    refute_nil ::Bundler::Changelogs::VERSION
  end

  def test_search
    Bundler::Changelogs::Command.new.exec(nil, [])
  end

  def test_search_with_groups
    Bundler::Changelogs::Command.new.exec(nil, %i[foo])

    assert true
    #assert Object.const_defined?(:Net)
    #refute Object.const_defined?(:Pry)
  end

  def test_search_with_path
    assert true
  end

end
