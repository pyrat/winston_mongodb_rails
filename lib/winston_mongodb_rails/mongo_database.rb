class MongoDatabase
  
  attr_reader :connection
  
  def initialize(options = {})
      
    options = options.symbolize_keys  
      
      
    if ['production', 'staging'].include? Rails.env

      @connection = Mongo::ReplSetConnection.new(options[:replicaset], :read => :secondary, :name => options[:replicaset_name])
      @connection.add_auth(options[:database], options[:username], options[:password])
      @connection.add_auth('admin', options[:username], options[:password])
    else
      url = "mongodb://#{options[:host]}"
      @connection = Mongo::Connection.from_uri(url)
    end

  end

  def all
    @connection.database_names
  end

  def collections(database_name)
    db = @connection.db(database_name)
    db.collection_names
  end

  def distinct(database, collection, field)
    db = @connection.db(database)
    coll = db.collection(collection)
    coll.distinct(field.to_s)
  end


  def records(database, collection, last = Time.now)
        
    db = @connection.db(database)
    coll = db.collection(collection)

    if row = coll.find().sort("_id", -1).limit(1).first
      keys = row.keys
      if keys.include?('updated_at')
        find_options = {"updated_at" => {"$lt" => last}}
        sort_options = [['updated_at', 'descending']]

      elsif keys.include?('created_at')
        find_options = {"created_at" => {"$lt" => last}}
        sort_options = [['created_at', 'descending']]
      else
        find_options = {}
      end
    else
      find_options = {}
    end
        
    query = coll.find(find_options).limit(25)

    if sort_options
      query.sort(sort_options)
    else
      query
    end
  end

  # Need to do some sort of skip and last chat.
  def capped_records(database, collection, conditions, last = Time.now)
    db = @connection.db(database)
    coll = db.collection(collection)
    conditions = conditions.merge({"timestamp" => {"$lt" => last}})
    coll.find(conditions).sort([["$natural", "-1"]]).limit(50)
  end


  # Need to do some sort of first and last chat.
  def range_records(database, collection, conditions, first = Time.now, last = Time.now, limit = 2000)
    db = @connection.db(database)
    coll = db.collection(collection)
    conditions = conditions.merge({"timestamp" => {"$lte" => last, "$gte" => first}})

    baseQuery = coll.find(conditions).sort([["$natural", "-1"]]).limit(limit)
  end

  def find(database, collection, id)
    db = @connection.db(database)
    coll = db.collection(collection)
    coll.find_one(:_id => BSON::ObjectId(id))
  end

  def update(database, collection, id, params)
    db = @connection.db(database)
    coll = db.collection(collection)
    s_params = params.stringify_keys
    coll.update({"_id" => BSON::ObjectId(id)}, {"$set" => s_params}, :safe => true)
  end
  
end
