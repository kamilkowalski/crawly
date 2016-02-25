require_relative "helper"

class ClusterTest < Minitest::Test
  def setup
    @bundle = Crawly::Bundle.new(CRAWLSPEC_FILE)
    @cluster = Crawly::Cluster.new(@bundle)
  end

  def test_start
    pid_dir = File.join(__dir__, "pids")
    Dir.mkdir(pid_dir) rescue nil

    fake_worker = Class.new(Crawly::Worker) do
      def work
        pid_dir = File.join(__dir__, "pids")
        File.write(File.join(pid_dir, "#{Process.pid}"), "created")
      end
    end

    Crawly::Cluster.const_set("Worker", fake_worker)
    @cluster.start

    pid_files = Dir["test/pids/*"]
    assert_equal 25, pid_files.count
    File.unlink *pid_files
    Dir.unlink pid_dir
  end
end
