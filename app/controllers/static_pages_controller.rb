class StaticPagesController < ApplicationController
  def home
  end

  def help
  end

  def about
  end

  def lobby
    @user = current_user
  end

  def play
  end
end
