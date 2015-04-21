
require 'httparty'

# # client_id = "XFMFMCH3CTS0SLTMBQ2KDTFHVJFNPWEPIQU151PPJF5RUZAF"
# # client_secret = "NIIUDV3OY5UE5TGZBODQRPS351IVGW5532CV5E4QCQ1VU4CH"

class FourSquare
  include HTTParty
  base_uri 'https://api.foursquare.com/v2'

  def initialize
    @options = { query: {client_id: ENV['client_id'], client_secret: ENV['client_secret'], v:20150403} }
  end

  def venue_photos(venue_id)
    self.class.get("/venues/#{venue_id}/photos", @options)
  end

  def venue_tips(venue_id, options)
    new_options = {query: @options[:query].merge(options)}
    self.class.get("/venues/#{venue_id}/tips", new_options)
  end

  def venue_menu(venue_id)
    self.class.get("/venues/#{venue_id}/menu", @options)
  end

  def venue_search(venue, place)
    new_options= {query: @options[:query].merge({query: venue, near: place, section: 'food'})}
    self.class.get("/venues/search", new_options)
  end

  def venue_url(venue_id)
    self.class.get("/venues/#{venue_id}", @options)
  end
end

  def get_restaurant_names(venue,place)
    results_hash = {}
    venue_search(venue,place)
  end
