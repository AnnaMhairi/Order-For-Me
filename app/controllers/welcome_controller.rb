require 'APICall'

class WelcomeController < ApplicationController
  # include APICall
  # before_filter :createfs

  def index
    # @foursquareapi = FourSquare.new
    render :index
  end

  def create
    # p params[:restaurant]
    # p params[:citystate]
    @x = get_names(params[:restaurant],params[:citystate])
    # @x
    render :create
  end



  private

  def get_names(restaurant_name, location)
    @foursquareapi = FourSquare.new
    results_hash = {}
    @foursquareapi
    results = @foursquareapi.venue_search(restaurant_name, location)
    results["response"]["venues"].each do|venue|

    if venue["categories"][0]["name"].include?("Restaurant")
      results_hash[venue["name"]] = venue["id"]
      end
    end
    return results_hash
  end

  # def createfs
  #   @foursquareapi = FourSquare.new
  # end
end

