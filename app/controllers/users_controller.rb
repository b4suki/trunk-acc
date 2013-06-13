class UsersController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
#  include AuthenticatedSystem
#  before_filter :login_required
#  access_control [:create, :new] => 'Administrator'
  before_filter :initiate_method
  
  # render new.rhtml
  def new
  end

  def create
    
    @user = User.new(params[:user])
    
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
  
  def inbox
    @user = current_user
    @mail = @user.mailbox[:inbox].latest_mail
  end
  
  def show_message
    @mail = Mail.find(params[:id])
    @mail.update_attribute(:read, true)
  end
  def delete_message
    @mail = Mail.find(params[:id])
    @mail.update_attribute(:trashed, true)
    redirect_to :action => :inbox
  end
  
  def compose_message
    if request.get?
      @message = Message.new
    else
      phil = current_user 
      todd = User.find(params[:message][:to]) 
      phil.send_message(todd, params[:message][:body], params[:message][:subject])
      redirect_to :action => :inbox
    end
  end
  
  def replay_message
    if request.get?
      @mail = Mail.find(params[:id])
    else
      @mail = Mail.find(params[:id])
      @mail.message.sender.reply_to_sender(@mail, params[:message][:body])
      redirect_to :action => :inbox
    end
  end

  private

  def initiate_method
    @title = "Pesan"
  end
end

