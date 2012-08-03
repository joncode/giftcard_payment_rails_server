module GiftsHelper
  
  def get_category_image(gift)
    case gift.item.category
    when 0
     "special_white.png"
    when 1
      "beer_white.png"
    when 2
      "wine_white.png"
    when 3
      "cocktail_white.png"
    when 4
      "shots_white.png"
    end
  end
  
end

# BEVERAGE_CATEGORIES = ['special', 'beer', 'wine', 'cocktail', 'shot']
