class Logger::SimpleFormatter
  def call(severity, time, progname, msg)
    t = time.strftime("%Y-%m-%d %H:%M:%S.") << time.usec.to_s[0..2].rjust(3)
    "#{t} [#{severity}] #{msg}\n"
  end
end

# https://stackoverflow.com/questions/13043968/how-to-call-silence-on-dalli-cache-store
# silence dalli caching, it will fill the disk
Rails.cache.silence!

Rails.application.configure do
  logger = ActiveSupport::TaggedLogging.new( ActiveSupport::Logger.new(STDOUT) )
  logger.level = Logger.const_get( ENV.fetch("RAILS_LOG_LEVEL", "DEBUG") ) 
  logger.formatter = Logger::SimpleFormatter.new

  if defined?(BetterErrors) && ActiveModel::Type::Boolean.new.cast( ENV.fetch("RAILS_LOGRAGE_ENABLED", "true") )
    config.lograge.enabled = true
    config.lograge.logger = logger
    config.lograge.ignore_actions = ['MonitoringController#healthcheckz']
    config.lograge.formatter = lambda do |data|
      output = []
      output << "#{data[:method]}"
      output << "#{data[:path]}"
      output << "code=#{data[:status]}"
      output << "format=#{data[:format]}"
      output << "duration=#{data[:duration] || 0}"
      output << "view=#{data[:view] || 0}"
      output << "db=#{data[:db] || 0}"
      output << "params=#{data[:params]}"

      output.join(' ').to_s
    end
    config.lograge.custom_options = lambda do |event|
      # capture parameters
      unwanted_keys = %w[format action controller utf8 authenticity_token]
      params = event.payload[:params].reject { |key,_| unwanted_keys.include? key }
      
      { 
        :params => params
      }
    end

    logger.info "Lograge logging enabled at level: #{ENV.fetch("RAILS_LOG_LEVEL", "DEBUG")}!"
  else
    config.logger = logger
    logger.info "Standard logging enabled at level: #{ENV.fetch("RAILS_LOG_LEVEL", "DEBUG")}!"
  end

  sql_logger = ActiveSupport::Logger.new(STDOUT)
  sql_logger.level = Logger.const_get( ENV.fetch("RAILS_SQL_LOG_LEVEL", ENV.fetch("RAILS_LOG_LEVEL", "DEBUG")))
  sql_logger.formatter = Logger::SimpleFormatter.new
  ActiveRecord::Base.logger = sql_logger
  #logger.info "Sql logging enabled at level: #{ENV.fetch("RAILS_SQL_LOG_LEVEL", ENV.fetch("RAILS_LOG_LEVEL", "DEBUG"))}"
end