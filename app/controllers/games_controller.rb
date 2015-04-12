class GamesController < ApplicationController
  #before_action :set_game, only: [:show, :edit, :update, :destroy]

  # GET /games
  # GET /games.json
  def index
    @games = Game.all
    
  end

  # GET /games/1
  # GET /games/1.json
  def show
    @game = Game.find(params[:id])
    user = current_user
    if user.game != 0 && params[:join] == "1" && user.game != @game.id
      flash.now[:warning] = "You cannot join more than one game at a time. You have been redirected."
      @game = Game.find(user.game)
    
    elsif (user.game == 0 && params[:join] == "1")
      
      #current_user.game = nil
      #current_user.save
      
      flash.now[:success] = "Game Successfully Joined!"
      assign_game_to_current_user(@game)
    end
  end

  # GET /games/new
  def new
    user = current_user
    if (user.game != 0)
      flash[:warning] = "You cannot join more than one game at a time. You have been redirected."
      redirect_to game_path(user.game)
  
    else
      @game = Game.new
    end
  end

  # GET /games/1/edit
  def edit
  end

  # POST /games
  # POST /games.json
  def create

    @game = Game.new(game_params)
    @game.update_attribute(:pending, true)
    @game.update_attribute(:done, false)
      if @game.save
        flash[:success] = "Game Successfully Created!"
        assign_game_to_current_user(@game)
        redirect_to games_path
      else
        render 'new'
      end
  end

  # PATCH/PUT /games/1
  # PATCH/PUT /games/1.json
  def update
    respond_to do |format|
      if @game.update(game_params)
        format.html { redirect_to @game, notice: 'Game was successfully updated.' }
        format.json { render :show, status: :ok, location: @game }
      else
        format.html { render :edit }
        format.json { render json: @game.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /games/1
  # DELETE /games/1.json
  def destroy
    @game.destroy
    respond_to do |format|
      format.html { redirect_to games_url, notice: 'Game was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_game
      @game = Game.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def game_params
      params.require(:game).permit(:name, :pending, :done)
    end
end
