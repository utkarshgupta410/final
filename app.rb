# Set up for the application and database. DO NOT CHANGE. #############################
require "sinatra"                                                                     #
require "sinatra/reloader" if development?                                            #
require "sequel"                                                                      #
require "logger"                                                                      #
require "twilio-ruby"                                                                 #
require "bcrypt"                                                                      #
connection_string = ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/development.sqlite3"  #
DB ||= Sequel.connect(connection_string)                                              #
DB.loggers << Logger.new($stdout) unless DB.loggers.size > 0                          #
def view(template); erb template.to_sym; end                                          #
use Rack::Session::Cookie, key: 'rack.session', path: '/', secret: 'secret'           #
before { puts; puts "--------------- NEW REQUEST ---------------"; puts }             #
after { puts; }                                                                       #
#######################################################################################

listings_table = DB.from(:listings)
reviews_table = DB.from(:reviews)
users_table = DB.from(:users)

# before do
#     @current_user = users_table.where(id: session["user_id"]).to_a[0]
# end

get "/" do
    puts listings_table.all
    @listings = listings_table.all.to_a
    view "listings"
end

get "/listings/:id" do
    @listing = listings_table.where(id: params[:id]).to_a[0]
    @review = reviews_table.where(listings_id: @listings[:id])
    # @going_count = rsvps_table.where(event_id: @event[:id], going: true).count
    # @users_table = users_table
    view "indlisting"
end

get "/listings/:id/reviews/new" do
    @listing = listings_table.where(id: params[:id]).to_a[0]
    view "new_review"
end