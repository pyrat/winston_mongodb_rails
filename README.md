# Winston Mongodb Rails

Initial alpha release, still tied to a rails application config. There are no test, and some tight coupling deep in the code. This is an internal tool in the early stages
of open source
Hopefully this should be improved in later releases.


## Installation

Add the gem to your Gemfile

    gem 'winston_mongodb_rails'
    
Add `config/initializers/mongo_logger.rb`

    app_config = Rails.application.config
    Mog = WinstonMongodbRails::MongoLogger.create_logger(app_config, ((app_config.paths.log.to_a rescue nil) || app_config.paths['log']).first)
    
    
For mongo configuration, you need to add the configuration of the mongodb database to `mongoid.yml` or `database.yml`
    
    production:
      username: username
      password: password
      database: logs
      replicaset: ['10.10.10.2:27017', '10.10.10.1:27017']
      replicaset_name: 'replicaset_name'
    
    
## Usage

    Mog.error "This is an error", object_to_inspect
    Mog.debug "Debug message"
    Mog.info "Info message"
    

