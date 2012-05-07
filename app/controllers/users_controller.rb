class UsersController < ApplicationController
  before_filter :authenticate, :except => [ :show, :new, :create ]
  before_filter :correct_user, :only => [ :edit, :update ]
  before_filter :admin_user, :only => :destroy
  before_filter :not_signed_in, :only => [ :new, :create ]

  def index
    @users = User.paginate(:page => params[:page])
    @title = 'All users'
  end

  def show
    # remember where to come back to in case a post gets deleted
    store_location
    @user = User.find(params[:id])
    @microposts = @user.microposts.paginate(:page => params[:page])
    @title = @user.name
  end

  def new
    @user = User.new
    @title = 'Sign up'
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      sign_in(@user)
      flash[:success] = "Welcome to the Sample App!"
      redirect_to @user
    else
      @title = 'Sign up'
      # Make sure the password fields are clear after failure
      @user.password = ''
      @user.password_confirmation = ''
      render :new
    end
  end

  def edit
    @title = 'Edit user'
  end

  def update
    if @user.update_attributes(params[:user])
      flash[:success] = "User updated"
      redirect_to @user
    else
      @title = 'Edit user'
      render 'edit'
    end
  end

def destroy
  if current_user == User.find(params[:id])
    flash[:notice] = "Self destruction is not allowed."
  else
    User.find(params[:id]).destroy
    flash[:success] = "User destroyed."
  end
  redirect_to users_path
end

  def following
    show_follow(:following)
  end

  def followers
    show_follow(:followers)
  end

  def show_follow(action)
    @title = action.to_s.capitalize
    @user = User.find(params[:id])
    @users = @user.send(action).paginate(:page => params[:page])
    render 'show_follow'
  end

  private

    def correct_user
      @user = User.find(params[:id])
      redirect_to root_path unless current_user?(@user)
    end

    def admin_user
      redirect_to(root_path) unless current_user.admin?
    end

    def not_signed_in
      redirect_to(root_path) unless not signed_in?
    end
end
