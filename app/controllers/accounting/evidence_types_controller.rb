class Accounting::EvidenceTypesController < ApplicationController
  before_filter :login_required
#  access_control [:index, :show] => "Administrator | Accounting | Kasir | Direktur | Staff IT | Direktur Utama"
#  access_control [:destroy, :new, :create, :edit, :update] => "Administrator | Accounting | Kasir"
  def index
    @evidence_types = AccountingEvidenceType.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @accounting_evidence_types }
    end
  end

  # GET /accounting_evidence_types/1
  # GET /accounting_evidence_types/1.xml
  def show
    @evidence_type = AccountingEvidenceType.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @evidence_type }
    end
  end

  # GET /accounting_evidence_types/new
  # GET /accounting_evidence_types/new.xml
  def new
    @evidence_type = AccountingEvidenceType.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @evidence_type }
    end
  end

  # GET /accounting_evidence_types/1/edit
  def edit
    @evidence_type = AccountingEvidenceType.find(params[:id])
  end

  # POST /accounting_evidence_types
  # POST /accounting_evidence_types.xml
  def create
    @evidence_type = AccountingEvidenceType.new(params[:evidence_type])

    respond_to do |format|
      if @evidence_type.save
        flash[:notice] = 'EvidenceType was successfully created.'
        format.html { redirect_to(accounting_evidence_type_path(@evidence_type)) }
        format.xml  { render :xml => @evidence_type, :status => :created, :location => @evidence_type }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @evidence_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /accounting_evidence_types/1
  # PUT /accounting_evidence_types/1.xml
  def update
    @evidence_type = AccountingEvidenceType.find(params[:id])

    respond_to do |format|
      if @evidence_type.update_attributes(params[:evidence_type])
        flash[:notice] = 'EvidenceType was successfully updated.'
        format.html { redirect_to(accounting_evidence_type_path(@evidence_type)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @evidence_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /accounting_evidence_types/1
  # DELETE /accounting_evidence_types/1.xml
  def destroy
    @evidence_type = AccountingEvidenceType.find(params[:id])
    @evidence_type.destroy

    respond_to do |format|
      format.html { redirect_to(accounting_evidence_types_url) }
      format.xml  { head :ok }
    end
  end
end
