require 'APICall'
require 'YelpCall'
require 'nokogiri'
require 'open-uri'
# require 'geocoder'

class WelcomeController < ApplicationController

  def index
    render :index
  end

  def create

    foursquarevenue = FourSquare.new
    api_search = foursquare_search(params[:restaurant], params[:citystate])
    @restaurant_search_results = get_names(api_search)

    # @x = Geocoder.search("San Francisco, CA")
    # @y = []

    # # p "*"*99
    # @y = @x.first.data["geometry"]["location"]
    # # # p @y
    # # p "*"*99
    # @z = foursquarevenue.trending_restaurants({ll: '37.7749495,-122.4194155', limit: 50, radius: 2000})
    # p "*"*99
    # p z
    # @y = Yelpz.new
    # @z = @y.search
    @business_names = []
    trending = Yelpiez.new
    @y = trending.search(params[:citystate])
    @y.businesses.each do |business|
      @business_names.push(business.name)
    end

    p "*" * 99
    p @z
    p params[:restaurant]
    p params[:citystate]
    p @y
    p @business_names
    render :json => {restaurant_search_results: @restaurant_search_results, api_search_results: api_search, x: @y, trending_businesses: @business_names }

  end

  def obtain_restaurants_with_menus(result_of_restaurant_search) #determines whether a restaurant id is able to return a menu object
    @foursquarevenue = FourSquare.new
    restaurants_with_menus = {}
    result_of_restaurant_search.each do |id, name|
      restaurants_with_menus[id]
      if @foursquarevenue.venue_menu(id)["response"]["menu"]["menus"]["count"] >= 1
        restaurants_with_menus[id] = name
      end
    end
    return restaurants_with_menus
  end

  def obtain_reviews_and_put_in_array(reviews_object)
    reviews = []
    reviews_object["response"]["tips"]["items"].each do |review|
      reviews.push(review["text"])
    end
    return reviews
  end

  def obtain_dish_names_and_put_in_array(menu_object)
    dishnames = []
    menu_object["response"]["menu"]["menus"]["items"].each do |menus|
      menus["entries"]["items"].each do |courses|
        courses["entries"]["items"].each do |dishes|
          dishnames.push(dishes["name"])
        end
      end
    end
    return dishnames
  end

  def photo_reel(photos)
    photo_array = []

    photos["response"]["photos"]["items"].each do |photo|
      photo_array << "#{photo["prefix"]}300x300#{photo["suffix"]}"
    end
    return photo_array
  end

  def show
    @foursquareapi = FourSquare.new
    @tips = @foursquareapi.venue_tips(params[:id], {sort: 'popular', limit: 200})
    @menu = @foursquareapi.venue_menu(params[:id])
    @url = @foursquareapi.venue_url(params[:id])
   #COPY THIS LINE AND ALL ASSOCIATED PHOTO METHODS
    @photos = @foursquareapi.venue_photos(params[:id])

    #GET ALL PHOTOS
    # prefix + size + suffix
    # https://irs0.4sqi.net/img/general/300x500/2341723_vt1Kr-SfmRmdge-M7b4KNgX2_PHElyVbYL65pMnxEQw.jpg.
    # @photo_array = []

    # @photos["response"]["photos"]["items"].each do |photo|
    #   @photo_array << "#{photo["prefix"]}300x300#{photo["suffix"]}"
    # end
    @photo_array = photo_reel(@photos)


    if @menu["response"]["menu"]["menus"]["count"] == 0

      @suggestion_objects = @foursquareapi.similar_venues(params[:id])
      @suggestions = {}
      @suggestion_objects["response"]["similarVenues"]["items"].each do |venue|
        @suggestions[venue["id"]] = venue["name"]
      end

      @suggestions_with_menu = obtain_restaurants_with_menus(@suggestions)

      render :json => {suggestions: @suggestions_with_menu, isSuggestion: true}
    else
      # GET ALL REVIEW TEXT
      @reviews = obtain_reviews_and_put_in_array(@tips)

      # GET ALL MENU ITEM TEXT
      @dishnames = obtain_dish_names_and_put_in_array(@menu)

      # GET ALL KEYWORD TEXT USING NOKOGIRI
    #GET VENUE NAME
    # @name = @url["response"]["venue"]["name"]

    # GET ALL KEYWORD TEXT USING NOKOGIRI
      @venue_url = @url["response"]["venue"]["canonicalUrl"]
      doc = Nokogiri::HTML(open(@venue_url))
      @tags = doc.xpath("//div[contains(@class,'tastes')]/ul/li[contains(@class,'taste')]/span[contains(@class,'pill')]").collect {|node| node.text.strip}

      #HASH WITH KEY TAG AND VALUE MENU ITEM ARRAY
      @menu_item_to_tag = menu_tag_association(@dishnames, @tags)
      #HASH WITH KEY TAG WORD AND VALUE ARRAY OF REVIEWS MENTIONING TAG WORD
      @tag_to_reviews = tag_review_association(@tags, @reviews)
      #HASH WITH MENU ITEM AS KEY AND ARRAY OF REVIEWS FOR THAT MENU ITEM AS THE VALUES
      @menu_with_reviews = menu_to_review_association(@tag_to_reviews, @menu_item_to_tag)
      render :json => {review_list_per_item: @menu_with_reviews, isSuggestion: false, photo_array: @photo_array }
    end
  end

  private

  def foursquare_search(restaurant_name, location)
    @foursquareapi = FourSquare.new
    @api_results = @foursquareapi.venue_search(restaurant_name, location)
    return @api_results
  end

  def get_names(api_result)
    @results_hash = {}
    @results = api_result
    @results["response"]["venues"].each do|venue|
    if venue["categories"][0]["name"].include?("Restaurant")
      @results_hash[venue["id"]] = venue["name"]
      end
    end
    return @results_hash
  end

  def menu_tag_association(dishnames, tags)
    relevant_tags = []
    relevant_tags_to_dishes = Hash.new()
    dishnames.each do |dish|
      relevant_tags_to_dishes[dish] = []
      tags.each do |tag|
        if dish.downcase.include?(tag.downcase) || "#{dish}s".downcase.include?(tag.downcase)
          relevant_tags_to_dishes[dish].push(tag)
        end
      end
    end
    relevant_array_of_tags_to_dishes = relevant_tags_to_dishes.sort_by { |key, value| value.length }.reverse
    relevant_tags_to_dishes = Hash[relevant_array_of_tags_to_dishes]
    return relevant_tags_to_dishes
  end

  def tag_review_association(tags, reviews)
    relevant_reviews_to_tags = {}

    tags.each do |tag|
      non_plural_tag = tag[0..-2]
      relevant_reviews_to_tags[tag] = []
      reviews.each do |review|
        if review.downcase.include?(tag.downcase) || review.downcase.include?(non_plural_tag.downcase)
          relevant_reviews_to_tags[tag].push(review)
        end
      end
    end
    return relevant_reviews_to_tags
  end

  def menu_to_review_association(tagreview_association, menutag_association)
    @menu_item_with_reviews = Hash.new()
    menutag_association.each do |menu_item, tags_for_menu_item|
      @menu_item_with_reviews[menu_item] = []
      tagreview_association.each do |each_of_all_tags, reviews_mentioning_tag|
        tags_for_menu_item.each do |tag_for_menu_item|
          reviews_mentioning_tag.each do |review_mentioning_tag|
            if tag_for_menu_item.downcase.include?(each_of_all_tags.downcase)
            #MAKE NEW HASH WITH KEY OF MENU ITEM AND VALUE BEING THE REVIEWS FOR THAT MENU ITEM
              @menu_item_with_reviews[menu_item].push(review_mentioning_tag)
            end
          end
        end
      end
    end
    @menu_item_with_reviews = @menu_item_with_reviews.sort_by { |key, value| value.length }.reverse
    @menu_item_with_reviews = Hash[@menu_item_with_reviews]
    return @menu_item_with_reviews
  end

end


