class PulsaSettingsController < ApplicationController
  before_filter :login_required, :initial_method
  skip_before_filter :verify_authenticity_token,
    :only => [:auto_complete_for_item_name]


  def index
    @settings = PulsaSetting.paginate :page => params[:page], :order => 'created_at DESC'
  end

  def new
    @setting = PulsaSetting.new
    render :layout => false
  end

  def create
    PulsaSetting.create(:item_id => params[:pulsa_setting][:item_id])
    redirect_to :action => "index"
  end

  def destroy
    setting = PulsaSetting.find(params[:id])
    setting.destroy
    redirect_to :action => "index"
  end

  def edit
    @setting = PulsaSetting.find(params[:id])
    render :layout => false
  end

  def update
    setting = PulsaSetting.find(params[:id])
    setting.update_attributes(params[:pulsa_setting] )
    redirect_to :action => "index"
  end

  def auto_complete_for_item_name
    search = params[:item][:name]
    @items = Item.find(:all, :conditions => ["name LIKE ? AND completed ='1'", "%#{search}%"])
    render :partial => "list_item"
  end
  
  private

  def initial_method
    @title = "DAFTAR SETTING PULSA"
  end
end
