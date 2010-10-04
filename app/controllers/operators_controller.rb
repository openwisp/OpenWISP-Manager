class OperatorsController < ApplicationController
  before_filter :load_wisp
  
  access_control :subject_method => :current_operator do
    default :deny

    allow :admin
    allow :wisp_admin, :of => :wisp, :to => [:index, :show, :new, :edit, :create, :update, :destroy]
    allow :wisp_operator, :of => :wisp, :to => [:show]
    allow :wisp_viewer, :of => :wisp, :to => [:show]
  end

  def load_wisp
    @wisp = Wisp.find(params[:wisp_id])
  end


  def index
    @operators = @wisp.operators
  end
  
  def new
    @operator = @wisp.operators.build
    @selected_roles = []
  end

  def edit
    @operator = @wisp.operators.find(params[:id])
    # subject.roles won't work!
    @selected_roles = @operator.roles
  end
  
  def create
    @operator = @wisp.operators.build(params[:operator])
    
		unless params[:roles].nil? or params[:roles].length == 0 
    	@selected_roles = Operator::ROLES & params[:roles]
		else
			@selected_roles = []
    end

    if @operator.save
      @selected_roles.each do |r|
        @operator.has_role!(r, @wisp)
      end
      respond_to do |format|
          flash[:notice] = t(:Account_registered)
          format.html { redirect_to(wisp_operators_url) }
      end
    else
      respond_to do |format|
        format.html { render :action => "new" }
      end
    end
  end
  
  def update
    @operator = @wisp.operators.find(params[:id])
    unless params[:roles].nil? or params[:roles].length == 0
      @selected_roles = Operator::ROLES & params[:roles]
    else
      @selected_roles = []
    end

    if @operator.update_attributes(params[:operator])
      @operator.has_no_roles!
      @selected_roles.each do |r|
        @operator.has_role!(r, @wisp)
      end
      respond_to do |format|
        flash[:notice] = t(:Account_updated)
        format.html { redirect_to(wisp_operators_url(@wisp)) }
      end
    else
      respond_to do |format|
        format.html { render :action => "edit" }
      end
    end
  end
  
  def destroy
    @operator = @wisp.operators.find(params[:id])
    @operator.has_no_roles!
    @operator.destroy

    respond_to do |format|
      format.html { redirect_to(wisp_operators_url(@wisp)) }
    end
  end
  
end
