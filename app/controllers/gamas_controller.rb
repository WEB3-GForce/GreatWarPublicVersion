class GamasController < ApplicationController
  #before_action :set_Gama, only: [:show, :edit, :update, :destroy]
  before_action :has_game_started?, only: [:index, :show, :edit, :update, :new, :create]

  # GET /Gamas
  # GET /Gamas.json
  def index
    @gamas = Gama.all
    user = current_user
    if user.game != 0 && params[:leave] == "1"
      flash.now[:success] = "You have left your current Gama"
      leave_game
    end
    
  end

  # GET /Gamas/1
  # GET /Gamas/1.json
  def show
    @gama = Gama.find(params[:id])
    user = current_user
    #current_user.Gama = 0
    #  current_user.save
    #@Gama.update_attribute(:pending, true)
    if user.game != 0 && user.game == @gama.id && !is_current_user_host?(@gama)
    	redirect_to "/play"
      
    elsif user.game != 0 && params[:join] == "1" && user.game != @gama.id
      flash.now[:warning] = "You cannot join more than one Game at a time. You have been redirected."
      @gama = Gama.find(user.game)
      if !is_current_user_host?(@gama)
      	redirect_to "/play"
      end
    
    elsif (user.game == 0 && params[:join] == "1")

	if !is_game_full?(@gama)
		if @gama.players == (@gama.limit.to_i - 1)
			@gama.update_attribute(:pending, false)
		end
		
		flash.now[:success] = "Game Successfully Joined!"
		assign_game_to_current_user(@gama)
		@gama.update_attribute(:players, @gama.players + 1)
		redirect_to "/play"
	else
		flash.now[:warning] = "Sorry, game is full"
		redirect_to games_path
	end
	  
    elsif (user.game != 0 && params[:join] != "1" && user.game == @gama.id)
    	if !is_current_user_host?(Gama.find(user.game))
    		redirect_to "/play"
    	end    
    end
  end

  # GET /Gamas/new
  def new
    user = current_user
    if (user.game != 0)
      flash[:warning] = "You cannot join more than one Gama at a time. You have been redirected."
      if !is_current_user_host?(Gama.find(user.game))
    		redirect_to "/play"
      else
        redirect_to gama_path(user.game)
      end 
      
    else
      @gama = Gama.new
    end
  end

  # GET /Gamas/1/edit
  def edit
  end

  # POST /Gamas
  # POST /Gamas.json
  def create

    @gama = Gama.new(gama_params)
      if @gama.save
        flash[:success] = "Game Successfully Created!"
        @gama.update_attribute(:pending, true)
    	@gama.update_attribute(:done, false)
    	@gama.update_attribute(:players, 1)
   	current_user.update_attribute(:host, true)
        assign_game_to_current_user(@gama)
        redirect_to gamas_path
      else
        render 'new'
      end
  end
  
  def start
  	@gama = Gama.find(params[:gama])
  	@players = players_in_game(@gama)
  	#puts @players
  	start_game(@players, @gama)
  end

  # PATCH/PUT /Gamas/1
  # PATCH/PUT /Gamas/1.json
  def update
    respond_to do |format|
      if @gama.update(gama_params)
        format.html { redirect_to @gama, notice: 'Gama was successfully updated.' }
        format.json { render :show, status: :ok, location: @gama }
      else
        format.html { render :edit }
        format.json { render json: @gama.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /Gamas/1
  # DELETE /Gamas/1.json
  def destroy
    @gama.destroy
    respond_to do |format|
      format.html { redirect_to gamas_url, notice: 'Gama was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_Gama
      @gama = Gama.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def gama_params
      params.require(:gama).permit(:name, :pending, :done)
    end
    
    def has_game_started?
    	
    end
end
