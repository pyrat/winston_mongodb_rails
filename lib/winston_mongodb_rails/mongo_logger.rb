module WinstonMongodbRails
  class MongoLogger < ActiveSupport::BufferedLogger

    # Aim to rely on the mongodb driver for replicaset chat.

    # Looks for configuration files in this order
    CONFIGURATION_FILES = ["mongoid.yml", "database.yml"]
    LOG_LEVEL_SYM = [:debug, :info, :warn, :error, :fatal, :unknown]

    def initialize(options={})
      path = options[:path] || File.join(Rails.root, "log/#{Rails.env}-mog.log")
      level = options[:level] || DEBUG
      @db_configuration = resolve_config
      internal_initialize
      super(path, level)
    rescue => e
      # should use a config block for this
      Rails.env.production? ? (raise e) : (puts "Using BufferedLogger due to exception: " + e.message)
    end

    def add(severity, message = nil, progname = nil, &block)
      
      # this writes to mongo
      mongo_record = {
        :level => LOG_LEVEL_SYM[severity].to_s,
        :timestamp => Time.now,
        :message => message,
        :application_name => @application_name,
        :meta => progname
      }

      insert_log_record(mongo_record, @safe_insert)
      super
    end


    private
    # facilitate testing
    def internal_initialize
      configure
      connect
    end

    def configure
      @mongo_database_name = @db_configuration['database'] || "logs"
      @mongo_collection_name = @db_configuration['collection_name'] || "logs"
      @application_name = @db_configuration['application_name'] || 'default'
      @safe_insert = @db_configuration['safe_insert'] || false
    end

    def resolve_config
      config = {}
      CONFIGURATION_FILES.each do |filename|
        config_file = Rails.root.join("config", filename)
        if config_file.file?
          config = YAML.load(ERB.new(config_file.read).result)[Rails.env]
          config = config['mongo'] if config.has_key?('mongo')
          break
        end
      end
      config
    end
    
    def connect
      @mongo_connection ||= MongoDatabase.new.connection
      @logs_database ||= @mongo_connection.db(@mongo_database_name)
      @logs_collection ||= @logs_database.collection(@mongo_collection_name)
    end
    
    # This inserts a log record into mongodb
    def insert_log_record(mongo_record, safe=false)
      @logs_collection.insert(mongo_record, :safe => safe)
    end

    class << self
      def create_logger(config, path)
        level = ActiveSupport::BufferedLogger.const_get(config.log_level.to_s.upcase)
        logger = MongoLogger.new(:path => path, :level => level)
        logger.auto_flushing = false if Rails.env.production?
        logger
      rescue StandardError => e
        logger = ActiveSupport::BufferedLogger.new(STDERR)
        logger.level = ActiveSupport::BufferedLogger::WARN
        logger.warn(
        "CentralLogger Initializer Error: Unable to access log file. Please ensure that #{path} exists and is chmod 0666. " +
        "The log level has been raised to WARN and the output directed to STDERR until the problem is fixed." + "\n" +
        e.message + "\n" + e.backtrace.join("\n")
        )
        logger
      end
    end

  end # class MongoLogger
end
