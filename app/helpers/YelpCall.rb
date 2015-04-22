require 'yelp'
require 'dotenv'
require 'httparty'
Dotenv.load

client = Yelp::Client.new({ consumer_key: ENV['consumer_key'],
                            consumer_secret: ENV['consumer_secret'],
                            token: ENV['token'],
                            token_secret: ENV['token_secret']
                          })

params = {sort: 2, limit: 10, category_filter: "restaurants"}

trending = client.search("San Francisco, CA", params)
trending.businesses.each do |business|
  p "#{business.name}: #{business.rating} (#{business.url})"
end

# class Yelpz
#   include HTTParty
#   base_uri 'https://api.yelp.com/v2'

#   def initialize
#     @options = { query: { consumer_key: ENV['consumer_key'],consumer_secret: ENV['consumer_secret'], token: ENV['token'], token_secret: ENV['token_secret'], location: "San Francisco, CA", sort: 2, limit: 10, category_filter: "restaurants"}}
#   end

#   def search
#     # new_options = {query: @options[:query].merge({})}
#     self.class.get("/search", @options)
#   end
# end

# trending = Yelpz.new
# p trending.search