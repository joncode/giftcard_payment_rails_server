class HomeController < ApplicationController
  
  def index
    respond_to do  |format|
      if signed_in?
        @user = current_user
        format.html
      else
        format.html { redirect_to choose_user_path }
      end
    end
  end
  
  def choose_user
     @users = User.order('id DESC')
  end
  
  def gift
  
  end
  
  def buy
    
  end
  
  def drinboard
    
  end
  
  def help 
  end
  
  def contact 
  end

  def about
  end
  
  def channel
    @micropost = current_user.microposts.build if signed_in?
    @feed_items = Micropost.all
  end
  
  def learn
  end
  
  def news
  end
  



end

