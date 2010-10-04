class CustomScriptsController < ApplicationController
  layout nil

  before_filter :load_wisp
  before_filter :load_access_point
    
  access_control :subject_method => :current_operator do
    default :deny

    allow :admin
    allow :wisp_admin, :of => :wisp, :to => [ :index, :new, :edit, :create, :update, :destroy ]
    allow :wisp_operator, :of => :wisp, :to => [ :index, :new, :edit, :create, :update, :destroy ]
    allow :wisp_viewer, :of => :wisp, :to => [:index]
  end
  
  def load_wisp
    @wisp = Wisp.find(params[:wisp_id])
  end

  def load_access_point
    @access_point = @wisp.access_points.find(params[:access_point_id])
  end

  # GET /wisps/:wisp_id/access_points/:access_point_id/custom_script
  def index
    @custom_scripts = @access_point.custom_scripts.find(:all)
    @custom_script_templates = @access_point.access_point_template.custom_script_templates.find(:all)

    respond_to do |format|
      format.html # index.html.erb
    end
  end
  
  # GET /wisps/:wisp_id/access_points/:access_point_id/custom_script_template/1
  def show
    @custom_script = @access_point.custom_script.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
    end
  end

  def new
    @custom_script = CustomScript.new()

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  def create
    @custom_script = @access_point.custom_scripts.new(params[:custom_script])

     respond_to do |format|
       if @custom_script.save
         @access_point.update_configuration
         format.html { redirect_to(wisp_access_point_custom_scripts_url(@wisp, @access_point)) }
       else
         format.html { render :action => "new" }
       end
     end
  end
  
  # GET /custom_script/1/edit
  def edit
    @custom_script = @access_point.custom_scripts.find(params[:id])
  end

  def update
    @custom_script = @access_point.custom_scripts.find(params[:id])
    respond_to do |format|
      if @custom_script.update_attributes(params[:custom_script])
        # Update Configuration
        @access_point.update_configuration
        format.html { redirect_to(wisp_access_point_custom_scripts_url(@wisp, @access_point)) }
      else
        format.html { render :action => "edit" }
        end
    end
  end

  def destroy
    @custom_script = CustomScript.find(params[:id])
    @custom_script.destroy
    
    @access_point.update_configuration
    respond_to do |format|
      format.html { redirect_to(wisp_access_point_custom_scripts_url(@wisp, @access_point)) }
    end
  end
end
