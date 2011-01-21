class AccessPointTemplatesController < ApplicationController

  before_filter :load_wisp, :except => [:ajax_stats, :list_access_points]
  before_filter :load_access_point_template, :except => [:index, :new, :create, :ajax_stats, :list_access_points]

  access_control :subject_method => :current_operator do
    default :deny

    allow :admin
    allow :wisp_admin, :of => :wisp, :to => [:show, :index, :new, :edit, :create, :update, :destroy, :list_access_points, :ajax_stats, :ajax_update]
    allow :wisp_operator, :of => :wisp, :to => [:show, :index, :new, :edit, :create, :update, :destroy, :list_access_points, :ajax_stats, :ajax_update]
  end
  
  def load_wisp
    @wisp = Wisp.find(params[:wisp_id])
  end
  
  def load_access_point_template
    @access_point_template = @wisp.access_point_templates.find(params[:id])
  end
  
  # GET /wisps/:wisp_id/access_point_templates
  def index
    @access_point_templates = @wisp.access_point_templates.find(:all)

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /wisps/:wisp_id/access_point_templates/1
  def show
    @radio_templates = @access_point_template.radio_templates
    @bridge_templates = @access_point_template.bridge_templates
    @l2vpn_templates = @access_point_template.l2vpn_templates
    
    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # GET /wisps/:wisp_id/access_point_templates/new
  def new
    @access_point_template = @wisp.access_point_templates.build()
    
    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /wisps/:wisp_id/access_point_templates/1/edit
  def edit

  end

  # POST /wisps/:wisp_id/access_point_templates
  def create
    @access_point_template = @wisp.access_point_templates.build(params[:access_point_template])
    @access_point_template.wisp = @wisp
        
    if @access_point_template.save
	  @access_point_template.touch(:committed_at) 
      respond_to do |format|
        format.html { redirect_to(wisp_access_point_template_url(@wisp, @access_point_template)) }
      end
    else
      respond_to do |format|
        format.html { render :action => "new" }
      end    
    end
  end

  # PUT /wisps/:wisp_id/access_point_templates/1
  def update
    if @access_point_template.update_attributes(params[:access_point_template])
      respond_to do |format|
        format.html { redirect_to(wisp_access_point_template_url(@wisp, @access_point_template)) }
      end
    else
      respond_to do |format|
        format.html { render :action => "edit" }
      end
    end
  end

  # DELETE /wisps/:wisp_id/access_point_templates/1
  def destroy
    @access_point_template.destroy

    respond_to do |format|
      format.html { redirect_to(wisp_access_point_templates_url(@wisp)) }
    end
  end

  # Method for calling access points list partial
  def list_access_points
    template_id = params[:template_id]
    render :partial => "access_points_list", :locals => { :access_point_template_id => template_id }
  end

  # Ajax Methods
  def ajax_stats
    @access_point_template = AccessPointTemplate.find(params[:id])

    respond_to do |format|
      format.html { render :partial => "stats", :object =>  @access_point_template }
    end
  end

end
