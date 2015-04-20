require 'APICall'
require 'nokogiri'
require 'open-uri'

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
    api_search = foursquare_search(params[:restaurant], params[:citystate])
    @x = get_names(api_search)
    # @x
    render :json => {x: @x}
  end


  #options: 1. check for single word match and add dish to count 2. check for exact match and only then add dish to count 3. check for 2 words in a row match and add that dish to count

  def show #THIS IS WHERE WE ARE RETRIEVING THE MENU AND REVIEWS FOR COMPARISON ==== MUST CREATE API METHODS TO RETRIEVE MENU AND REVIEWS(TIPS)
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

    # GET ALL KEYWORD TEXT USING NOKOGIRI
      @venue_url = @url["response"]["venue"]["canonicalUrl"]
      doc = Nokogiri::HTML(open(@venue_url))
      @tags = doc.xpath("//div[contains(@class,'tastes')]/ul/li[contains(@class,'taste')]/span[contains(@class,'pill')]").collect {|node| node.text.strip}


    @match_array = []

    @dishnames.each do |dish|
      @reviews.each do |review|
        review.downcase.split(" ").each do |review_word|
          dish.downcase.split(" ").each do |dish_word|
            if review_word.include?(dish_word) #&& dish_word != "and" && dish_word != "or" && dish_word != "in"
              @match_array.push(dish)
            end
          end
        end
      end
    end

  # @match_reviews = {}
  # @review_array = []

  # @dishnames.each do |dish|
  #   @reviews.each do |review|
  #     if @review_array.include?(review) == false
  #       if review.include?(dish)
  #         @match_reviews[dish] = @review_array
  #         @review_array.push(review)
  #       end
  #     end
  #   end
  # end





    # p @match_reviews
    # p @match_reviews
   # @dishnames.each do |dish|
   #    @reviews.each do |review|
   #      review.downcase.split(" ").each_with_index do |review_word ,index|
   #        dish.downcase.split(" ").each_with_index do |dish_word, i|


   #            if review[index] == dish[i] && review[index+1] == dish[i+1]

   #              # .include?(dish_word) && dish_word != "and" && dish_word != "or" && dish_word != "in" && dish_word != "thai"
   #              @match_array.push(dish)
   #            elsif review[index] == dish[i] && review[index+1] == dish[i+1] && review[index+2] == dish[i+2]

   #              # .include?(dish_word) && dish_word != "and" && dish_word != "or" && dish_word != "in" && dish_word != "thai"
   #              @match_array.push(dish)
   #            elsif dish.length == 1 && dish_word == review_word
   #              @match_array.push(dish)
   #            end
   #          end
   #        end
   #      end
   #    end


    @match_hash = Hash.new(0)

    @match_array.each do |counter|
      @match_hash[counter] += 1
    end


    @x = @match_hash.sort_by { |key, value| value }.reverse
    "*"*99
    @match_hash = Hash[@x]


    # @review_hash = Hash.new(Array.new)

    # @match_hash.keys.each do |menu_item|
    #   @review_hash[menu_item]
    #   menu_item.split(" ").each do |item|
    #     @reviews.each do |review|
    #       if review.include?(item) && @review_hash.include?(review) == false
    #         # @item_position = i
    #         # @review_position = i
    #         @review_hash[menu_item].push(review)
    #       end
    #     end
    #     @review_hash[menu_item] = @review_hash[menu_item].uniq
    #   end
    # end

    # p @review_hash

    #HASH WITH KEY TAG AND VALUE MENU ITEM ARRAY
    @menu_item_to_tag = menu_tag_association(@dishnames, @tags)
    #HASH WITH KEY TAG WORD AND VALUE ARRAY OF REVIEWS MENTIONING TAG WORD
    @tag_to_reviews = tag_review_association(@tags, @reviews)
    #HASH WITH MENU ITEM AS KEY AND ARRAY OF REVIEWS FOR THAT MENU ITEM AS THE VALUES
    @menu_with_reviews = menu_to_review_association(@tag_to_reviews, @menu_item_to_tag)

    # @compare_tag_to_reviews = check_review_for_tag(@reviews, @menu_item_to_tag)

    # @relevant_reviews = return_relevant_reviews(@reviews, @compare_tag_to_reviews)

    render :json => {tips: @tips, reviews: @reviews, finalz: @match_hash, venue_url: @venue_url, tagz: @tags, most_reviewed_dishes: @menu_item_to_tag, tag_with_reviews: @tag_to_reviews, review_list_per_item: @menu_with_reviews}
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
          # relevant_tags.push(tag)
          relevant_tags_to_dishes[dish].push(tag)
        end
      end
    end
    relevant_array_of_tags_to_dishes = relevant_tags_to_dishes.sort_by { |key, value| value.length }.reverse
    "*"*99
    relevant_tags_to_dishes = Hash[relevant_array_of_tags_to_dishes]
    return relevant_tags_to_dishes
  end

  def tag_review_association(tags, reviews)
    relevant_reviews_to_tags = {}

    tags.each do |tag|
      non_plural_tag = tag[0..-2]
      relevant_reviews_to_tags[tag] = []
      reviews.each do |review|
        p "*"*99
        p review
        p "*"*99
        p tag

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

  # def check_review_for_tag(reviews, menu_tag_hash)
  #   top_dishes = []
  #   top_dish_reviews = []
  #   reviews.each do |review|
  #     menu_tag_hash.each do |item, tags|
  #       tags.each do |tag|
  #         if review.downcase.include?(tag.downcase)
  #           top_dishes.push(item)
  #           top_dish_reviews.push(review)
  #         end
  #       end
  #     end
  #   end
  #   @top = Hash.new(0)

  #   top_dishes.each do |counter|
  #     @top[counter] += 1
  #   end

  #   @x = @top.sort_by { |key, value| value }.reverse
  #   @top = Hash[@x]
  #   return [@top, top_dish_reviews]
  # end

  # def return_relevant_reviews(reviews, top_dish_count_hash)
  #   relevant_reviews = []
  #   reviews.each do |review|

  # end
  # def get_url(api_result)
  #   @search_results = api_result
  #   @url_array = []
  #   @search_results["response"]["venues"].each do |venue|
  #     venue["categories"].each do |category|
  #       @url_array.push(category["icon"]["prefix"])
  #     end
  #   end
  #   return @url_array
  # end

  # def createfs
  #   @foursquareapi = FourSquare.new
  # end
end

# @review_hash = Hash.new(Array.new)

# @match_hash.keys.each do |menu_item|
#   @review_hash[menu_item]
#   @reviews.each do |review|
#     menu_item.split(" ").each do |item|
#     if review.include?(item)
#       @review_hash[menu_item].push(review)
#     end
#   end
#   @review_hash[menu_item] = @review_hash[menu_item].uniq
# end

# @review_hash

