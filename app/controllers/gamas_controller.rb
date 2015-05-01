=begin
  The Gamas controller handles all the webpages related to games, including
  their creation, instantiation, and deletion.
=end

class GamasController < ApplicationController
  before_action :set_Gama, only: [:show, :edit, :update, :destroy, :join]

  # GET /Gamas
  def index
    @gamas = Gama.all
    user = current_user
  end

  # GET /Gamas/gama_id
  def show
    @gama = Gama.find(params[:id])
    user = current_user

    if user.gama_id == @gama.id
      redirect_to "/play"
    end
  end

  # GET /Gamas/new
  def new
    user = current_user
    if user.gama
      flash[:warning] = "You cannot join more than one Gama at a time. You have been redirected."
      redirect_to "/play"
    end
    @gama = Gama.new
  end

  # GET /Gamas/gama_id/edit
  def edit
  end

  # POST /Gamas/new
  def create
    user = current_user

    # couples a user with a newly created game
    @gama = user.build_gama(gama_params)
    @gama.limit = 2
    @gama.pending = true
    @gama.done = false
    if @gama.save
      flash[:success] = "Game Successfully Created!"
      user.update_attribute(:host, true)
      redirect_to '/play'
    else
      render 'new'
    end
  end

  # PUT /Gamas/join/gama_id
  def join
    user = current_user
    if !user.gama
      if @gama.full?
        flash[:warning] = "Sorry, game is full."
        redirect_to gamas_path
      else
        @gama.users << user
        @gama.save
        if @gama.full?
          @gama.pending = false
          @gama.save
          @gama.notify(user)
          if @gama.full?
            @gama.pending = false
            @gama.save
            @gama.start
          end
          flash[:success] = "Game successfully joined!"
          redirect_to "/play"
        end
        flash[:success] = "Game successfully joined!"
        redirect_to "/play"
      end
    else
      flash[:warning] = "You are already in a game."
      redirect_to "/play"
    end
  end

  # PUT /Gamas/leave/gama_id
  def leave
    user = current_user
    SocketController.leave_game(user) unless user.gama.pending?
    user.gama.gameover
    # notify other players
    flash[:success] = "You've left the game."
    redirect_to gamas_path
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

  # Never trust parameters from the scary internet, only allow the white list 
  # through.
  def gama_params
    params.require(:gama).permit(:name)
  end
end
