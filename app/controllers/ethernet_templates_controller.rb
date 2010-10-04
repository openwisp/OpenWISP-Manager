class EthernetTemplatesController < ApplicationController
  layout nil

  before_filter :load_wisp
  before_filter :load_access_point_template
  before_filter :load_ethernet_template, :except => [ :index, :new, :create ]
    
  access_control :subject_method => :current_operator do
    default :deny

    allow :admin
    allow :wisp_admin, :of => :wisp, :to => [:show, :index, :new, :edit, :create, :update, :destroy]
    allow :wisp_operator, :of => :wisp, :to => [:show, :index, :new, :edit, :create, :update, :destroy]
    allow :wisp_viewer, :of => :wisp, :to => [:show, :index]
  end

  def load_wisp
    @wisp = Wisp.find(params[:wisp_id])
  end

  def load_access_point_template
    @access_point_template = @wisp.access_point_templates.find(params[:access_point_template_id])
  end
  
  def load_ethernet_template
    @ethernet_template = @access_point_template.ethernet_templates.find(params[:id]) 
  end

  def index
    @ethernet_templates = @access_point_template.ethernet_templates.all

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def show

    respond_to do |format|
      format.html # show.html.erb
    end
  end

  def new
    @ethernet_template = EthernetTemplate.new()

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  def edit
    
  end

  def create
    @ethernet_template = @access_point_template.ethernet_templates.new(params[:ethernet_template])
    
    respond_to do |format|
      if @ethernet_template.save
        #flash[:notice] = 'Ethernet NIC was successfully created.'
        format.html { redirect_to(wisp_access_point_template_ethernet_templates_url(@wisp, @access_point_template)) }
      else
        format.html { render :action => "new" }
      end
    end
  end

  def update

    respond_to do |format|
      if @ethernet_template.update_attributes(params[:ethernet_template])
        format.html { redirect_to(wisp_access_point_template_ethernet_templates_url(@wisp, @access_point_template)) }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  def destroy
    @ethernet_template.destroy

    respond_to do |format|
      format.html { redirect_to(wisp_access_point_template_ethernet_templates_url(@wisp, @access_point_template)) }
    end
  end
    
end
