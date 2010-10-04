class L2vpnTemplatesController < ApplicationController
  layout nil

  before_filter :load_wisp
  before_filter :load_access_point_template
    
  access_control :subject_method => :current_operator do
    default :deny

    allow :admin
    allow :wisp_admin, :of => :wisp, :to => [:show, :index, :new, :edit, :create, :update, :destroy]
    allow :wisp_operator, :of => :wisp, :to => [ :index, :new, :edit, :create, :update, :destroy ]
    allow :wisp_viewer, :of => :wisp, :to => [:index]
  end

  def load_wisp
    @wisp = Wisp.find(params[:wisp_id])
  end
  
  def load_access_point_template
    @access_point_template = @wisp.access_point_templates.find(params[:access_point_template_id])
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
