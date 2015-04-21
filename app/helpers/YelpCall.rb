require 'yelp'
require 'dotenv'
Dotenv.load

client = Yelp::Client.new({ consumer_key: ENV['consumer_key'],
                            consumer_secret: ENV['consumer_secret'],
                            token: ENV['token'],
                            token_secret: ENV['token_secret']
                          })

params = {sort: 2, limit: 10, category_filter: "restaurants"}

p client.search("sf", params)