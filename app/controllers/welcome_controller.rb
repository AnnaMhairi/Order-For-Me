require 'APICall'
require 'nokogiri'
require 'open-uri'

class WelcomeController < ApplicationController

  def index
    render :index
  end

  def create
    api_search = foursquare_search(params[:restaurant], params[:citystate])
    @x = get_names(api_search)
    render :json => {x: @x}
  end

  def show
    @foursquareapi = FourSquare.new
    @tips = @foursquareapi.venue_tips(params[:id], {sort: 'popular', limit: 200})
    @menu = @foursquareapi.venue_menu(params[:id])
    @url = @foursquareapi.venue_url(params[:id])

    @dishnames = []
    @reviews = []

    # GET ALL REVIEW TEXT
    @tips["response"]["tips"]["items"].each do |review|
      @reviews.push(review["text"])
    end
    # GET ALL MENU ITEM TEXT
    @menu["response"]["menu"]["menus"]["items"].each do |menus|
      menus["entries"]["items"].each do |courses|
        courses["entries"]["items"].each do |dishes|
          @dishnames.push(dishes["name"])
        end
      end
    end

    #GET VENUE NAME
    @name = @url["response"]["venue"]["name"]

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

    render :json => {review_list_per_item: @menu_with_reviews}
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
    @menu_item_with_reviews = @menu_item_with_reviews.sort_by { |key, value| p value.length }.reverse
    @menu_item_with_reviews = Hash[@menu_item_with_reviews]
    return @menu_item_with_reviews
  end

end


