class AccessPointGroupsController < ApplicationController
  before_filter :load_wisp
  before_filter :load_access_point_group, :except => [ :index, :new, :create ]

  access_control :subject_method => :current_operator do
    default :deny

    allow :admin
    allow :wisp_admin, :of => :wisp, :to => [:show, :index, :new, :edit, :create, :edit, :update, :destroy]
    allow :wisp_operator, :of => :wisp, :to => [:show, :index, :new, :edit, :create, :edit, :update, :destroy]
    allow :wisp_viewer, :of => :wisp, :to => [:show, :index]
  end
  
  def load_wisp
    @wisp = Wisp.find(params[:wisp_id])
  end

  def load_access_point_group
    @access_point_group = @wisp.access_point_groups.find(params[:id])
  end
  
  
  # GET /wisps/:wisp_id/access_point_groups
  def index
    @access_point_groups = @wisp.access_point_groups

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /wisps/:wisp_id/access_point_groups/1
  def show

    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # GET /wisps/:wisp_id/access_point_groups/new
  def new
    @access_point_group = @wisp.access_point_groups.new
    @selected_access_points = []
    
    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /wisps/:wisp_id/access_point_groups/1/edit
  def edit
    @selected_access_points = @access_point_group.access_points.collect { |h| h.id }
    
  end

  # POST /wisps/:wisp_id/access_point_groups
  def create
    @access_point_group = @wisp.access_point_groups.new(params[:access_point_group])

    @selected_access_points = params[:access_points].nil? ? nil : params[:access_points].collect { |h| h.to_i }

    @access_point_group.access_points = []
    unless params[:access_points].nil?
      params[:access_points].each { |hid|
         @access_point_group.access_points << @wisp.access_points.find(hid)
      }
    end
    
    respond_to do |format|
      if @access_point_group.save
        flash[:notice] = t(:AccessPointGroup_was_successfully_created)
#        format.html { redirect_to(wisp_access_point_group_url(@wisp, @access_point_group)) }
        format.html { redirect_to(wisp_access_point_groups_url(@wisp)) }
      else
        format.html { render :action => "new" }
      end
    end
  end

  # PUT /wisps/:wisp_id/access_point_groups/1
  def update
    @selected_access_points = params[:access_points].nil? ? nil : params[:access_points].collect { |h| h.to_i }

    @access_point_group.access_points = []
    unless params[:access_points].nil?
      params[:access_points].each { |hid|
         @access_point_group.access_points << @wisp.access_points.find(hid)
      }
    end

    respond_to do |format|
      if @access_point_group.update_attributes(params[:access_point_group])
        flash[:notice] = t(:AccessPointGroup_was_successfully_updated)
#        format.html { redirect_to(wisp_access_point_group_url(@wisp, @access_point_group)) }
        format.html { redirect_to(wisp_access_point_groups_url(@wisp)) }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  # DELETE /wisps/:wisp_id/access_point_groups/1
  def destroy
    @access_point_group.destroy

    respond_to do |format|
      format.html { redirect_to(wisp_access_point_groups_url) }
    end
  end
  
end
