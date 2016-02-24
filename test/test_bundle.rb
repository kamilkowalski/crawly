require_relative "helper"

class BundleTest < Minitest::Test
  def setup
    @bundle = Crawly::Bundle.new
  end

  def test_defaults
    assert_nil @bundle[:dbconfig]
    assert_nil  @bundle[:entry_point]
    assert_equal false, @bundle[:continue]
    assert_equal 5, @bundle[:cluster_size]
    assert_equal :info, @bundle[:log_level]
    assert_empty @bundle[:filters]
  end

  def test_getter
    assert_equal nil, @bundle[:dbconfig]
    assert_raises Crawly::ConfigError do
      @bundle[:foobar]
    end
  end

  def test_dbconfig
    @bundle.dbconfig({
      host: "localhost"
    })

    assert_equal({host: "localhost"}, @bundle[:dbconfig])
  end

  def test_entry_point
    @bundle.entry_point "http://www.google.com"
    assert_equal "http://www.google.com", @bundle[:entry_point]
  end

  def test_append_filter
    # Incorrect type of filter
    assert_raises Crawly::ConfigError do
      @bundle.append_filter 5
    end

    # Incorrect arity of filter
    assert_raises Crawly::ConfigError do
      @bundle.append_filter -> (a, b) { [a, b] }
    end

    filter = -> (a) { a }
    @bundle.append_filter filter
    assert_equal filter, @bundle[:filters].first
    assert_equal 1, @bundle[:filters].size
  end

  def test_clear_filters!
    @bundle.append_filter -> (a) { a }
    @bundle.clear_filters!
    assert_empty @bundle[:filters]
  end

  def test_cluster_size
    assert_raises Crawly::ConfigError do
      @bundle.cluster_size "foo"
    end

    @bundle.cluster_size 15
    assert_equal 15, @bundle[:cluster_size]
  end

  def test_log_level
    assert_raises Crawly::ConfigError do
      @bundle.log_level :foo
    end

    @bundle.log_level :debug
    assert_equal :debug, @bundle[:log_level]

    @bundle.log_level "info"
    assert_equal :info, @bundle[:log_level]

    @bundle.log_level :warn
    assert_equal :warn, @bundle[:log_level]

    @bundle.log_level "error"
    assert_equal :error, @bundle[:log_level]
  end

  def test_continue
    assert_raises Crawly::ConfigError do
      @bundle.continue 5
    end

    @bundle.continue true
    assert_equal true, @bundle[:continue]
  end

  def test_loading_crawlspec
    @bundle = Crawly::Bundle.new(CRAWLSPEC_FILE)

    if ENV["TRAVISCI"].nil?
      assert_equal({
        host: "localhost",
        dbname: "crawly-test",
        user: "crawly",
        password: "crawly"
      }, @bundle[:dbconfig])
    else
      assert_equal({
        host: "localhost",
        dbname: "crawly-test",
        user: "postgres"
      }, @bundle[:dbconfig])
    end

    assert_equal "http://www.cnn.com", @bundle[:entry_point]
    assert_equal 1, @bundle[:filters].size
    assert_equal true, @bundle[:continue]
    assert_equal 25, @bundle[:cluster_size]
    assert_equal :warn, @bundle[:log_level]
  end
end
