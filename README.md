# Winston Mongodb Rails

Initial alpha release, still tied to a rails application config. There are no test, and some tight coupling deep in the code. 
Hopefully this should be improved in later releases.


## Installation

Add the gem to your Gemfile

    gem 'winston_mongodb_rails'
    
Add `config/initializers/mongo_logger.rb`

    app_config = Rails.application.config
    Mog = WinstonMongodbRails::MongoLogger.create_logger(app_config, ((app_config.paths.log.to_a rescue nil) || app_config.paths['log']).first)
    
## Usage

    Mog.error "This is an error", object_to_inspect
    Mog.debug "Debug message"
    Mog.info "Info message"
    

