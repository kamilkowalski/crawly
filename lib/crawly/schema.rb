module Crawly
  class Schema
    def initialize(db, bundle)
      @db     = db
      @bundle = bundle
    end

    def prepare
      if @bundle[:dbconfig].nil?
        raise ConfigError.new("Database config missing")
      else
        create_table
        unless @bundle[:continue]
          truncate_table
          insert_entry_point
        end
      end
    end

    private

    def create_table
      @db.exec <<-SQL
        CREATE TABLE crawldocs
        (id SERIAL, link VARCHAR(255), processed BOOLEAN, content TEXT)
      SQL
    rescue PG::DuplicateTable
    end

    def truncate_table
      @db.exec <<-SQL
        TRUNCATE TABLE crawldocs
      SQL
    end

    def insert_entry_point
      if @bundle[:entry_point].nil?
        raise ConfigError.new("Entry point undefined")
      else
        @db.prepare(
          "document_seed",
          "INSERT INTO crawldocs (link, processed, content) VALUES ($1, 'f', '')"
        )

        @db.exec_prepared("document_seed", [@bundle[:entry_point]])
      end
    end
  end
end
