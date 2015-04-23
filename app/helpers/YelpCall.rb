require 'yelp'
require 'dotenv'
require 'httparty'
Dotenv.load

# puts "*" * 85
# puts ENV["TOPHER"]

class Yelpiez
  def initialize
    @client = Yelp::Client.new({ consumer_key: ENV['consumer_key'],
                            consumer_secret: ENV['consumer_secret'],
                            token: ENV['token'],
                            token_secret: ENV['token_secret']
                          })
  end

  def search(location)
    params = {sort: 2, limit: 10, category_filter: "restaurants"}

    @client.search(location, params)
    # trending.businesses.each do |business|
    #   p "#{business.name}: #{business.rating} (#{business.url})"
    # end
  end
end

# client = Yelp::Client.new({ consumer_key: ENV['consumer_key'],
#                             consumer_secret: ENV['consumer_secret'],
#                             token: ENV['token'],
#                             token_secret: ENV['token_secret']
#                           })

# params = {sort: 2, limit: 10, category_filter: "restaurants"}

# trending = client.search("San Francisco, CA", params)
# @topher = "stuf"
# trending.businesses.each do |business|
#   p "#{business.name}: #{business.rating} (#{business.url})"
# end

# class Yelpz
#   include HTTParty
#   base_uri 'https://api.yelp.com/v2'

#   def initialize
#     @options = { query: { oauth_consumer_key: "ld12A471HIJu4Z0NfJNxXQ",consumer_secret: "7yaqnWnQhTHx3eHvs4Y_3T17Ub0", oauth_token: "n2BethL0P3PnlFmNdey9n_jPtgWmPj3z", token_secret: "dN-vLqV1e9wBY_62_Axz9n2yfWM", location: "San Francisco, CA", sort: 2, limit: 10, category_filter: "restaurants"}}
#   end

#   def search
#     p "*"*99

#     # new_options = {query: @options[:query].merge({})}
#     self.class.get("/search", @options)
#   end
# end

# trending = Yelpz.new
# p trending.search

# searching = Yelpiez.new