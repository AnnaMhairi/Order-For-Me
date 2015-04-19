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


  #options: 1. check for single word match and add dish to count 2. check for exact match and only then add dish to count 3. check for 2 words in a row match and add that dish to count

  def show #THIS IS WHERE WE ARE RETRIEVING THE MENU AND REVIEWS FOR COMPARISON ==== MUST CREATE API METHODS TO RETRIEVE MENU AND REVIEWS(TIPS)
    @foursquareapi = FourSquare.new
    @tips = @foursquareapi.venue_tips(params[:id], {sort: 'popular'})
    @menu = @foursquareapi.venue_menu(params[:id])

    @dishnames = []
    @reviews = []

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
        review.downcase.split(" ").each do |review_word|
          dish.downcase.split(" ").each do |dish_word|


              if review_word.include?(dish_word) #&& dish_word != "and" && dish_word != "or" && dish_word != "in"
                @match_array.push(dish)
              end
            end
          end
        end
      end

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

    render :json => {matches: @match_array, allreviews: @reviews, menu: @dishnames, finalz: @match_hash}
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

