class AccessPointTemplatesController < ApplicationController

  before_filter :load_wisp
  before_filter :load_access_point_template, :except => [:index, :new, :create, :ajax_stats]

  access_control do
    default :deny

    actions :index, :show, :ajax_stats do
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

  # Ajax Methods
  def ajax_stats
    @access_point_template = AccessPointTemplate.find(params[:id])

    respond_to do |format|
      format.html { render :partial => "stats", :object =>  @access_point_template }
    end
  end

  private

  def load_access_point_template
    @access_point_template = @wisp.access_point_templates.find(params[:id])
  end
end
