class RadioTemplatesController < ApplicationController
  layout nil
  
  before_filter :load_wisp
  before_filter :load_access_point_template

  access_control :subject_method => :current_operator do
    default :deny

    allow :admin
    allow :wisp_admin, :of => :wisp, :to => [ :index, :new, :edit, :create, :update, :destroy ]
    allow :wisp_operator, :of => :wisp, :to => [ :index, :new, :edit, :create, :update, :destroy ]
    allow :wisp_viewer, :of => :wisp, :to => [:index, :edit, :update]
  end
  
  def load_wisp
    @wisp = Wisp.find(params[:wisp_id])
  end

  def load_access_point_template
    @access_point_template = @wisp.access_point_templates.find(params[:access_point_template_id])
  end  
  
  # GET /wisps/:wisp_id/access_point_templates/:access_point_template_id/radio_templates
  def index
    @radio_templates = @access_point_template.radio_templates.find(:all)

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /wisps/:wisp_id/access_points/:access_point_template_id/radios/1
  def show
    @radio_template = @access_point_template.radio_templates.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # GET /wisps/:wisp_id/access_points/:access_point_template_id/radios/new
  def new
    @radio_template = @access_point_template.radio_templates.build()
    RadioTemplate::MAX_VAPS.times { @radio_template.vap_templates.build() }

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /wisps/:wisp_id/access_points/:access_point_template_id/radios/1/edit
  def edit
    @radio_template = @access_point_template.radio_templates.find(params[:id])
    (RadioTemplate::MAX_VAPS - @radio_template.vap_templates.length).times { @radio_template.vap_templates.build }
  end

  # POST /wisps/:wisp_id/access_points/:access_point_template_id/radios
  def create
    @radio_template = @access_point_template.radio_templates.build(params[:radio_template])

    respond_to do |format|
      if @radio_template.save
        #flash[:notice] = 'Radio was successfully created.'
        format.html { redirect_to(wisp_access_point_template_radio_templates_url(@wisp, @access_point_template)) }
      else
        format.html { render :action => "new" }
      end
    end
  end

  # PUT /wisps/:wisp_id/access_points/:access_point_template_id/radios/1
  def update
    @radio_template = @access_point_template.radio_templates.find(params[:id])
    respond_to do |format|
      if @radio_template.update_attributes(params[:radio_template])
        #flash[:notice] = 'Radio was successfully updated.'
        format.html { redirect_to(wisp_access_point_template_radio_templates_url(@wisp, @access_point_template)) }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  # DELETE /wisps/:wisp_id/access_points/:access_point_template_id/radios/1
  def destroy
    @radio_template = @access_point_template.radio_templates.find(params[:id])
    @radio_template.destroy

    respond_to do |format|
      format.html { redirect_to(wisp_access_point_template_radio_templates_url(@wisp, @access_point_template)) }
    end
  end
end
