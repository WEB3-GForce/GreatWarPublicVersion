=begin
  The Users controller handles all the webpages that have to do with user
  creation, editing, deletiong, etc.
=end

class UsersController < ApplicationController
  # We only allow access certain sites (all, edit, update) to those users
  # that are already logged in
  before_action :logged_in_user, only: [:all, :edit, :update]

  # We don't allow random people to edit other peoples' information
  before_action :correct_user,   only: [:edit, :update]

  # GET Users/new
  def new
    @user = User.new
  end

  # GET Users/id
  def show
    @user = User.find(params[:id])
  end

  # GET Users
  def all
    @users = User.paginate(page: params[:page])
  end

  # POST Users/new
  def create
    @user = User.new(user_params)
    if @user.save
      log_in @user
      flash[:success] = "Welcome to the Great War!"
      redirect_to @user
    else
      render 'new'
    end
  end

  # PATCH/PUT Users/id
  def edit
    @user = User.find(params[:id])
  end

  # PATCH/PUT Users/id
  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      flash[:success] = "Information Updated!"
      redirect_to @user
    else
      render 'edit'
    end
  end


  private

  def user_params
    params.require(:user).permit(:name, :email, :password,
                                 :password_confirmation)
  end

  # Confirms a logged-in user.
  def logged_in_user
    unless logged_in?
      store_location
      flash[:danger] = "Please log in."
      redirect_to login_url
    end
  end

  # Confirms the correct user.
  def correct_user
    @user = User.find(params[:id])
    redirect_to(root_url) unless current_user?(@user)
  end
end
