class L2vpnTemplatesController < ApplicationController
  layout nil

  before_filter :load_wisp
  before_filter :load_access_point_template
    
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
  end

  # GET /wisps/:wisp_id/access_point_templates/:access_point_template_id/l2vpn_templates
  def index
    @l2vpn_templates = @access_point_template.l2vpn_templates.find(:all)

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /wisps/:wisp_id/access_point_templates/:access_point_template_id/l2vpn_templates/1
  def show
    @l2vpn_template = @access_point_template.l2vpn_templates.find(params[:id])
    
    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # GET /wisps/:wisp_id/access_point_templates/:access_point_template_id/l2vpn_templates/new
  def new
    @l2vpn_template = @access_point_template.l2vpn_templates.build()

    @servers_select = {}
    @wisp.l2vpn_servers.each { |s| @servers_select[s.name] = s.id }
        
    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /wisps/:wisp_id/access_point_templates/:access_point_template_id/l2vpn_templates/1/edit
  def edit
    @l2vpn_template = @access_point_template.l2vpn_templates.find(params[:id])
    
    @servers_select = {}
    @wisp.l2vpn_servers.each { |s| @servers_select[s.name] = s.id }
        
  end

  # POST /wisps/:wisp_id/access_point_templates/:access_point_template_id/l2vpn_templates
  def create
    @l2vpn_template = @access_point_template.l2vpn_templates.build(params[:l2vpn_template])
    @l2vpn_template.tap_template = TapTemplate.new( :l2vpn_template => @l2vpn_template )

    @servers_select = {}
    @wisp.l2vpn_servers.each { |s| @servers_select[s.name] = s.id }

    respond_to do |format|
      if @l2vpn_template.save
        @l2vpn_template.tap_template.save!
        #flash[:notice] = 'Vpn was successfully created.'
        format.html { redirect_to(wisp_access_point_template_l2vpn_templates_url(@wisp, @access_point_template)) }
      else
        format.html { render :action => "new" }
      end
    end
  end

  # PUT /wisps/:wisp_id/access_point_templates/:access_point_template_id/l2vpn_templates/1
  def update
    @l2vpn_template = @access_point_template.l2vpn_templates.find(params[:id])

    @servers_select = {}
    @wisp.l2vpn_servers.each { |s| @servers_select[s.name] = s.id }

    respond_to do |format|
      if @l2vpn_template.update_attributes(params[:l2vpn_template])
        #flash[:notice] = 'Vpn was successfully updated.'
        format.html { redirect_to(wisp_access_point_template_l2vpn_templates_url(@wisp, @access_point_template)) }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  # DELETE /wisps/:wisp_id/access_point_templates/:access_point_template_id/l2vpn_templates/1
  def destroy
    @l2vpn_template = @access_point_template.l2vpn_templates.find(params[:id])
    @l2vpn_template.destroy

    respond_to do |format|
      format.html { redirect_to(wisp_access_point_template_l2vpn_templates_url(@wisp, @access_point_template)) }
    end
  end
end
