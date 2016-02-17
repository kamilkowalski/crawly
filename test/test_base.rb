require_relative "helper"

class BaseTest < Minitest::Test
  def test_greet
    crawly = Crawly::Base.new
    assert_equal "Hello, world!", crawly.greet
  end
end
