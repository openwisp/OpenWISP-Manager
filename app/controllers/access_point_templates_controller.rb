class AccessPointTemplatesController < ApplicationController

  before_filter :load_wisp, :except => [:ajax_stats, :list_access_points]
  before_filter :load_access_point_template, :except => [:index, :new, :create, :ajax_stats, :list_access_points]

  access_control do
    default :deny

    actions :index, :show do
      allow :wisps_viewer
      allow :access_point_templates_viewer, :of => :wisp
    end

    actions :new, :create do
      allow :wisps_creator
      allow :access_point_templates_creator, :of => :wisp
    end

    actions :edit, :update do
      allow :wisps_manager
      allow :access_point_templates_manager, :of => :wisp
    end

    actions :destroy do
      allow :wisps_destroyer
      allow :access_point_templates_destroyer, :of => :wisp
    end

    # TODO: :ajax_stats and :list_access_points should be moved somewhere else
    allow all, :to => [:ajax_stats, :list_access_points]
  end
  
  def load_wisp
    #@wisp = current_operator.wisp or Wisp.find(params[:wisp_id])
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
