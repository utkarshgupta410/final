# Set up for the application and database. DO NOT CHANGE. #############################
require "sinatra"                                                                     #
require "sinatra/reloader" if development?                                            #
require "sequel"                                                                      #
require "logger"                                                                      #
require "twilio-ruby"                                                                 #
require "bcrypt"
require "geocoder"                                                                      #
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

before do
    @current_user = users_table.where(id: session["user_id"]).to_a[0]
end

get "/" do
    puts listings_table.all
    @listings = listings_table.all.to_a
    view "listings"
end

get "/listings/:id" do
    @listing = listings_table.where(id: params[:id]).to_a[0]
    @review = reviews_table.where(listings_id: @listing[:id])
    @users_table = users_table
    view "individual_listing"
end

get "/new" do
    view "new_listing"
end

get "/new/create" do
        locationammend = params["location"]
        locationammend << " Evanston"
        listings_table.insert(title: params["title"],
                       buildtype: params["buildtype"],
                       avgrent: params["avgrent"],
                       rooms: params["rooms"], 
                       location: locationammend)
        view "new_create"
end

get "/listings/:id/reviews/new" do
    @listing = listings_table.where(id: params[:id]).to_a[0]
    view "new_review"
end

get "/listings/:id/reviews/create" do
    puts params
    @listing = listings_table.where(id: params[:id]).to_a[0]
    reviews_table.insert(listings_id: params["id"],
                       user_id: session["user_id"],
                       rating: params["rating"],
                       comments: params["comments"])
    view "create_review"
end

get "/users/new" do
    view "new_user"
end

post "/users/create" do
    puts params
    hashed_password = BCrypt::Password.create(params["password"])
    users_table.insert(name: params["name"], email: params["email"], password: hashed_password)

    account_sid = "AC0fcdfd2d20ec626046ab9567949c4e12"
    auth_token = "edb27044107f1ec1689544e81181092e"
    client = Twilio::REST::Client.new(account_sid, auth_token)

    client.messages.create(
    from: "+12075219142", 
    to: "+919838070934",
    body: "Thank you for signing up with the Kellogg Housing Platform!"
    )
    
    view "create_user"
end

get "/logins/new" do
    view "new_login"
end

post "/logins/create" do
    user = users_table.where(email: params["email"]).to_a[0]
    # puts BCrypt::Password::new(user[:password])
    if user && BCrypt::Password::new(user[:password]) == params["password"]
        session["user_id"] = user[:id]
        @current_user = user
        
        redirect "/"
    else
        view "create_login_failed"
    end
end

get "/logout" do
    session["user_id"] = nil
    @current_user = nil
    view "logout"
end