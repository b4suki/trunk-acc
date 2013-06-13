# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem
  layout 'login_page'
  
  # render new.rhtml
  def new
  end
  
  def show
    render :action => 'new'  
  end
  
  def create
    self.current_user = User.authenticate(params[:login], params[:password])
    if logged_in?
      if params[:remember_me] == "1"
        current_user.remember_me unless current_user.remember_token?
        cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
      end
      render :update do |page|
        page.redirect_to "/"
      end
    else
      render :update do |page|
        #page.visual_effect(:shake,"form",:distance => "3",:duration => 1)
        page.call "ajax_login_flash_appear", "Username dan Password yang anda masukkan salah"
      end
    end
  end

  def destroy
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
#    flash[:notice] = "Anda berhasil keluar dari aplikasi."
    redirect_back_or_default('/')
  end
end
