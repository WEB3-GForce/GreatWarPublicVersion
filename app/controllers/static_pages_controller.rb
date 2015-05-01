=begin
  The Static Pages controller handles all the static webpages that we see
  on the website.
=end

class StaticPagesController < ApplicationController

  # GET /
  def home
  end

  # GET /help
  def help
  end

  # GET /about
  def about
  end

  # GET /lobby
  def lobby
    @user = current_user
  end

  # GET /play
  def play
  end
end
