require "nokogiri"
require "open-uri"
require "pg"

module Crawly
  class Worker
    def initialize(master, bundle:, log:)
      @master   = master
      @bundle   = bundle
      @log      = log
      @pid      = Process.pid
      @running  = false

      setup_database
      prepare_queries
    end

    def work
      @running = true

      Signal.trap "SIGINT", "IGNORE"
      Signal.trap "SIGTERM" do
        @running = false
      end

      @log.info "Starting worker #{@pid}"

      while(@running) do
        result = @db.exec_prepared("document_select")
        result.each do |row|
          crawl(row["link"])
        end
      end

      @log.info "Stopping worker #{@pid}"
    end

    private

    def setup_database
      unless @bundle[:dbconfig].nil?
        @db = PG.connect(@bundle[:dbconfig])
        Schema.new(@db, @bundle).prepare
      else
        raise ConfigError.new("Database configuration missing")
      end
    end

    def prepare_queries
      @db.prepare(
        "document_find",
        "SELECT COUNT(*) FROM crawldocs WHERE link = $1"
      )

      @db.prepare(
        "document_select",
        "SELECT link FROM crawldocs WHERE processed = 'f' LIMIT 1"
      )

      @db.prepare(
        "document_insert",
        "INSERT INTO crawldocs (link, processed, content) VALUES ($1, 'f', '')"
      )

      @db.prepare(
        "document_lock",
        "UPDATE crawldocs SET processed = 't' WHERE link=$1"
      )

      @db.prepare(
        "document_update",
        "UPDATE crawldocs SET processed = 't', content=$1 WHERE link=$2"
      )
    end

    def process_document(url, content)
      @bundle[:content_filters].each do |filter|
        content = filter.call(content)
        break if content.nil?
      end

      @db.exec_prepared("document_update", [content, url])
    end

    def extract_links(document)
      links = document.xpath("//a[@href]").map do |node|
        node.attribute("href").content
      end.select do |link|
        @bundle[:link_filters].any? do |filter|
          filter.call(link)
        end
      end

      links.each do |l|
        result = @db.exec_prepared("document_find", [l])
        if result.getvalue(0, 0).to_i == 0
          @db.exec_prepared("document_insert", [l])
        end
      end
    end

    def crawl(url)
      @log.info "Scraping URL: #{url}"
      @db.exec_prepared("document_lock", [url])
      document = Nokogiri::HTML(open(url))
      process_document(url, document)
      extract_links(document)
    rescue RuntimeError => e
      @log.error e.to_s
    end
  end
end
