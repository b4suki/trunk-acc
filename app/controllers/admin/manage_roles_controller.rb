class Admin::ManageRolesController < ApplicationController
  
#  before_filter :login_required, :set_access_control, :initial_method
  before_filter :login_required, :initial_method
#  access_control [:index, :update, :edit, :destroy, :create, :new,
#    :set_rule, :create_rule, :new_modul, :create_modul, :new_action, :create_action,
#    :delete_modul, :edit_action, :update_action, :edit_modul, :update_modul, :delete_action
#  ] => 'Administrator & ( !Direktur | !Pembelian | !Kas_Bank | !Petty_Cash | !Inventory )'
  
  def index
    @roles = Role.find(:all)
    @moduls = Modul.find(:all)
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @roles}
      format.xml  { render :xml => @moduls}
    end
  end
  
  def new
    @role = Role.new
    render :layout => false
  end
  
  def create
    @role = Role.new(params[:role])
    respond_to do |format|
      if @role.save
        flash[:notice] = 'Role was successfully created.'
        format.html { redirect_to(admin_manage_roles_path) }
        format.xml  { render :xml => @role, :status => :created, :location => @role }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @role.errors, :status => :unprocessable_entity }
      end
    end    
  end
  
  def destroy
    @role = Role.find(params[:id])
    @role.users.clear
    @role.destroy
    respond_to do |format|
      format.html { redirect_to(admin_manage_roles_path) }
      format.xml  { head :ok }
    end
  end
  
  def edit
    @role = Role.find(params[:id])
    render :layout => false
  end
  
  def update
    @role = Role.find(params[:id])
    respond_to do |format|
      if @role.update_attributes(params[:role])
        flash[:notice] = 'Role was successfully updated.'
        format.html { redirect_to(admin_manage_roles_path) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @role.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def set_rule
    @role = Role.find(params[:id])
    @app_menus = AccountingAppMenu.all(:order => "sequence")
    render :layout => false
  end
  
  def create_rule
    role = Role.find(params[:role_id])

    role.menu_assignments.each do |menu_assignment|
      menu_assignment.role_sub_menu_assignments.each do |sub_menu_assignment|
        sub_menu_assignment.destroy
      end
      menu_assignment.destroy
    end

    1.upto(params[:menu_count].to_i) do |x|
      role_menu_assignment = RoleMenuAssignment.create(:role_id => role.id, :menu_id => params["menu_id_#{x}"]) if params["cb_menu_#{x}"]=="on"
      if params["sub_menu_count_#{x}"].to_i > 0
        1.upto(params["sub_menu_count_#{x}"].to_i) do |y|
          role_menu_assignment.role_sub_menu_assignments << RoleSubMenuAssignment.new(:sub_menu_id => params["sub_menu_id_#{x}_#{y}"]) if params["cb_sub_menu_#{x}_#{y}"]=="on"
        end
      end
    end
    respond_to do |format|
      if role.save
        flash[:notice] = "Hak akses berhasil dibuat"
        format.html { redirect_to(admin_manage_roles_path) }
        format.xml  { head :ok }
      end
    end
  end
  
  def new_modul
    @modul = Modul.new
  end
  
  def create_modul
    @modul = Modul.new(params[:modul])
    respond_to do |format|
      if @modul.save
        flash[:notice] = 'Modul was successfully created.'
        format.html { redirect_to(admin_manage_roles_path) }
        format.xml  { render :xml => @modul, :status => :created, :location => @modul }
      else
        format.html { render :action => "new_modul" }
        format.xml  { render :xml => @modul.errors, :status => :unprocessable_entity }
      end
    end      
  end
  
  def new_action
    @a = Action.new
  end
  
  def create_action
    @a = Action.new(params[:a])
    respond_to do |format|
      if @a.save
        flash[:notice] = 'Action was successfully created.'
        format.html { redirect_to(admin_manage_roles_path) }
        format.xml  { render :xml => @a, :status => :created, :location => @a }
      else
        format.html { render :action => "new_action" }
        format.xml  { render :xml => @a.errors, :status => :unprocessable_entity }
      end
    end      
  end
  
  def delete_modul
    @modul = Modul.find(params[:id])
    @modul.destroy
    respond_to do |format|
      format.html { redirect_to(admin_manage_roles_path) }
      format.xml  { head :ok }
    end
  end
  
  def delete_action
    @action = Action.find(params[:id])
    @action.destroy
    respond_to do |format|
      format.html { redirect_to(admin_manage_roles_path) }
      format.xml  { head :ok }
    end
  end
  
  def edit_modul
    @modul = Modul.find(params[:id])
  end
  
  def update_modul
    @modul = Modul.find(params[:id])
    respond_to do |format|
      if @modul.update_attributes(params[:modul])
        flash[:notice] = 'Modul was successfully updated.'
        format.html { redirect_to(admin_manage_roles_path) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit_modul" }
        format.xml  { render :xml => @modul.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def edit_action
    @a = Action.find(params[:id])
  end
  
  def update_action
    @a = Action.find(params[:id])
    respond_to do |format|
      if @a.update_attributes(params[:a])
        flash[:notice] = 'Action was successfully updated.'
        format.html { redirect_to(admin_manage_roles_path) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit_action" }
        format.xml  { render :xml => @a.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  private
  
  def initial_method
    @title = "DAFTAR HAK AKSES"
  end
end
