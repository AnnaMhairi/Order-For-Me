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
    render :json => {x: @x}
  end

  def show #THIS IS WHERE WE ARE RETRIEVING THE MENU AND REVIEWS FOR COMPARISON ==== MUST CREATE API METHODS TO RETRIEVE MENU AND REVIEWS(TIPS)
    @foursquareapi = FourSquare.new
    @tips = @foursquareapi.venue_tips(params[:id], {sort: 'popular'})
    @menu = @foursquareapi.venue_menu(params[:id])

    @dishnames = []
    @reviews = []

    # p "*"*99
    # @menu["response"]["menu"]["menus"]["items"].each do |menus|
    #   @dishnames.push(menus["entries"]["items"])
    # end
    # p "*"*99
    @tips["response"]["tips"]["items"].each do |review|
      @reviews.push(review["text"])
    end

    @menu["response"]["menu"]["menus"]["items"].each do |menus|
      menus["entries"]["items"].each do |courses|
        courses["entries"]["items"].each do |dishes|
          @dishnames.push(dishes["name"])
        end
      end
    end

    @match_array = []

    @dishnames.each do |dish|
      @reviews.each do |review|
        if review.downcase.include?(dish.downcase)
          @match_array.push(dish)
        end
      end
    end

    render :json => {tips: @match_array, allreviews: @reviews, menu: @dishnames}
  end

  private

  def get_names(restaurant_name, location)
    @foursquareapi = FourSquare.new
    results_hash = {}
    @foursquareapi
    results = @foursquareapi.venue_search(restaurant_name, location)
    results["response"]["venues"].each do|venue|

    if venue["categories"][0]["name"].include?("Restaurant")
      results_hash[venue["id"]] = venue["name"]
      end
    end
    return results_hash
  end

  # def createfs
  #   @foursquareapi = FourSquare.new
  # end
end

