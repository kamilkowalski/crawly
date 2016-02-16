require "minitest/autorun"
require "crawly"

class BaseTest < Minitest::Test
  def test_greet
    crawly = Crawly::Base.new
    assert_equal "Hello, world!", crawly.greet
  end
end
