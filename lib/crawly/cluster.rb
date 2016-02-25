require "logger"

module Crawly
  class Cluster
    attr_reader :workers

    def initialize(bundle)
      @bundle     = bundle
      @workers    = []
      @size       = bundle[:cluster_size]
      @log        = Logger.new(STDOUT)
      @log.level  = Logger.const_get(bundle[:log_level].to_s.upcase)
    end

    def start
      master = Process.pid

      @size.times do
        pid = fork { spawn_worker(master) }
        @log.info "Spawned worker #{pid}"
        @workers << pid
      end


      Signal.trap "TERM" do
        stop_workers
      end

      Signal.trap "INT" do
        stop_workers
      end

      Process.waitall
    end

    private

    def stop_workers
      @log.info "Stopping workers"
      @workers.each do |pid|
        Process.kill "TERM", pid
      end

      begin
        Process.waitall
      rescue Interrupt
        @log.warn "Cluster stopping workers interrupted"
      end

      @workers = []
    end

    def spawn_worker(master)
      Worker.new(master, bundle: @bundle, log: @log).work
    rescue Interrupt
      @log.warn "Cluster worker spawn interrupted"
    end
  end
end
