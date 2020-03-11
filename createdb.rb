# Set up for the application and database. DO NOT CHANGE. #############################
require "sequel"                                                                      #
connection_string = ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/development.sqlite3"  #
DB = Sequel.connect(connection_string)                                                #
#######################################################################################

# Database schema - this should reflect your domain model
DB.create_table! :listings do
  primary_key :id
  String :title
  String :buildtype
  Boolean :avgrent
  String :location
  String :rooms
end
DB.create_table! :reviews do
  primary_key :id
  foreign_key :listings_id
  foreign_key :user_id
  Boolean :rating
  String :comments, text: true
end
DB.create_table! :users do
  primary_key :id
  String :name
  String :email
  String :password
end

# Insert initial (seed) data
listings_table = DB.from(:listings)

listings_table.insert(title: "E2", 
                    buildtype: "hotel",
                    avgrent: 2000,
                    location: "E2 Apartments",
                    rooms: "500+")

listings_table.insert(title: "Optima Horizons", 
                    buildtype: "Building",
                    avgrent: 1800,
                    location: "Optima Horizons")
