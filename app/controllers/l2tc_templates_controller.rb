class L2tcTemplatesController < ApplicationController
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
  
  # GET /wisps/:wisp_id/access_point_templates/:access_point_template_id/l2tc_templates
  def index
    @l2tc_templates = @access_point_template.l2tc_templates

    respond_to do |format|
      format.html # index.html.erb
    end
  end
  
  def edit
    @l2tc_template = @access_point_template.l2tc_templates.find(params[:id])
  
    params[:shapeables] = {}
    params[:shapeables][:output_band] = @l2tc_template.shapeable_template.output_band
    params[:subinterfaces] = {}
    i = 0
    @l2tc_template.shapeable_template.subinterfaces.each do |s|
      params[:subinterfaces]["#{i}"] = {}
      params[:subinterfaces]["#{i}"][:output_band_percent] = s.output_band_percent
      i += 1
    end
    
  end

  def update
    @l2tc_template = @access_point_template.l2tc_templates.find(params[:id])

    result = true
    
    L2tcTemplate.transaction do
      @l2tc_template.shapeable_template.output_band = params[:shapeables][:output_band]
      if @l2tc_template.shapeable_template.save    
        i = 0
        @l2tc_template.shapeable_template.subinterfaces.each do |s|
          s.output_band_percent = params[:subinterfaces]["#{i}"][:output_band_percent]
          unless s.save
            result = false
            raise ActiveRecord::Rollback
          end
          i += 1
        end
      else
        result = false
        raise ActiveRecord::Rollback
      end
      unless @l2tc_template.validate
        result = false
        raise ActiveRecord::Rollback
      end
    end
    
    respond_to do |format|
      if result and @l2tc_template.update_attributes(params[:l2tc_template])
        format.html { 
          redirect_to(wisp_access_point_template_l2tc_templates_url(@wisp, @access_point_template)) 
        }
      else
        format.html { render :action => "edit" }
      end
    end
  end
  
  def destroy
    @l2tc_template = @access_point_template.l2tc_templates.find(params[:id])
    @l2tc_template.shapeable_template.output_band = nil
    @l2tc_template.shapeable_template.subinterfaces.each do |s|
      s.output_band_percent = nil
      s.save!
    end
    @l2tc_template.shapeable_template.save!

    respond_to do |format|
      format.html { redirect_to(wisp_access_point_template_l2tc_templates_url(@wisp, @access_point_template)) }
    end
  end
  
end