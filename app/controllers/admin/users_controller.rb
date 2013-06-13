class Admin::UsersController < ApplicationController
  
  before_filter :login_required, :initial_method
#  access_control [:index, :update, :edit, :destroy, :create, :new] => 'Administrator & ( !Direktur | !Pembelian | !Kas_Bank | !Petty_Cash | !Inventory )'
  def index
    @users = User.filter_find params[:filter], :all, :order => 'id'
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @users}
    end
  end
  
  def new
    @user = User.new
    render :layout => false
  end
  
  def create
    @user = User.new(params[:user])
    @user.roles << Role.find(params[:role]) if params[:role]
    
    respond_to do |format|
      if @user.save
        flash[:notice] = 'Data Pengguna berhasil dibuat.'
        format.html { redirect_to(admin_users_path) }
        format.xml  { render :xml => @user, :status => :created, :location => @user }
      else
        flash[:error] = 'Data Pengguna gagal dibuat.'
        format.html { render :action => "new" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end    
  end
  
  def destroy
    @user = User.find(params[:id])
    @user.roles.clear
    if @user.destroy
      flash[:notice] = 'Data Pengguna berhasil dihapus.'
    else
      flash[:error] = 'Data Pengguna gagal dihapus.'
    end
    respond_to do |format|
      format.html { redirect_to(admin_users_path) }
      format.xml  { head :ok }
    end
  end
  
  def edit
    @user = User.find(params[:id])
    render :layout => false
  end
  
  def update
    @user = User.find(params[:id])
    @user.roles.clear
    @user.roles << Role.find(params[:role]) if params[:role]
    respond_to do |format|
      if @user.update_attributes(params[:user])
        flash[:notice] = 'Data Pengguna berhasil diupdate.'
        format.html { redirect_to(admin_users_path) }
        format.xml  { head :ok }
      else
        flash[:error] = 'Data Pengguna gagal diupdate.'
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  private
  
  def initial_method
    @title = "DAFTAR PENGGUNA"
  end
end
