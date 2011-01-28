class CustomScriptTemplatesController < ApplicationController
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
  
  def load_wisp
    @wisp = Wisp.find(params[:wisp_id])
  end

  def load_access_point_template
    @access_point_template = @wisp.access_point_templates.find(params[:access_point_template_id])
  end

  # GET /wisps/:wisp_id/access_point_templates/:access_point_template_id/custom_script_templates
  def index
    @custom_script_templates = @access_point_template.custom_script_templates.find(:all)

    respond_to do |format|
      format.html # index.html.erb
    end
  end
  
  # GET /wisps/:wisp_id/access_points/:access_point_template_id/custom_script_template/1
  def show
    @custom_script_template = @access_point_template.custom_script_templates.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
    end
  end

  def new
    @custom_script_template = CustomScriptTemplate.new()

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  def create
    @custom_script_template = @access_point_template.custom_script_templates.new(params[:custom_script_template])

     respond_to do |format|
       if @custom_script_template.save
         format.html { redirect_to(wisp_access_point_template_custom_script_templates_url(@wisp, @access_point_template)) }
       else
         format.html { render :action => "new" }
       end
     end
  end
  
  # GET /custom_script_templates/1/edit
  def edit
    @custom_script_template = @access_point_template.custom_script_templates.find(params[:id])
  end

  def update
    @custom_script_template = @access_point_template.custom_script_templates.find(params[:id])
    respond_to do |format|
      if @custom_script_template.update_attributes(params[:custom_script_template])
        format.html { redirect_to(wisp_access_point_template_custom_script_templates_url(@wisp, @access_point_template)) }
      else
        format.html { render :action => "edit" }
        end
    end
  end

  def destroy
    @custom_script_template = CustomScriptTemplate.find(params[:id])
    @custom_script_template.destroy
    
    respond_to do |format|
      format.html { redirect_to(wisp_access_point_template_custom_script_templates_url(@wisp, @access_point_template)) }
    end
  end
end
