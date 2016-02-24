module Crawly
  class Bundle

    def initialize(crawlspec = nil)
      @crawlspec = crawlspec
      set_defaults
      load_crawlspec
    end

    def [](var_name)
      var_symbol = "@#{var_name}".to_sym
      if instance_variable_defined?(var_symbol)
        instance_variable_get(var_symbol)
      else
        raise ConfigError.new("Undefined variable #{var_name}")
      end
    end

    def dbconfig(dbconfig)
      @dbconfig = dbconfig
    end

    def entry_point(entry_point)
      @entry_point = entry_point
    end

    def append_filter(filter)
      unless filter.is_a?(Proc)
        raise ConfigError.new("Filter must be a proc")
      end

      if filter.arity != 1
        raise ConfigError.new("Filter arity must be /1")
      end

      @filters << filter
    end

    def clear_filters!
      @filters.clear
    end

    def cluster_size(size)
      if size.is_a?(Numeric)
        @cluster_size = size
      else
        raise ConfigError.new("Cluster size not a number: #{@size}")
      end
    end

    def log_level(level)
      level = level.to_sym
      log_levels = %i(debug info warn error)

      if log_levels.include?(level)
        @log_level = level
      else
        raise ConfigError.new("Log level must be one of: #{log_levels}")
      end
    end

    def continue(continue)
      if continue.is_a?(TrueClass) || continue.is_a?(FalseClass)
        @continue = continue
      else
        raise ConfigError.new("Continue must be a boolean")
      end
    end

    private

    def set_defaults
      @dbconfig     = nil
      @entry_point  = nil
      @continue     = false
      @cluster_size = 5
      @log_level    = :info
      @filters      = []
    end

    def load_crawlspec
      unless @crawlspec.nil?
        contents = File.read(@crawlspec)
        eval(contents, binding, __FILE__, __LINE__)
      end
    end
  end

  class ConfigError < StandardError
  end
end
