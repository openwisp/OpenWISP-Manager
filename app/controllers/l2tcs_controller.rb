class L2tcsController < ApplicationController
  layout nil

  before_filter :load_wisp
  before_filter :load_access_point
    
  access_control :subject_method => :current_operator do
    default :deny

    allow :admin
    allow :wisp_admin, :of => :wisp, :to => [:show, :index, :new, :edit, :create, :update, :destroy]
    allow :wisp_operator, :of => :wisp, :to => [ :index, :new, :edit, :create, :update, :destroy ]
    allow :wisp_viewer, :of => :wisp, :to => [:index, :edit, :update]
  end

  def load_wisp
    @wisp = Wisp.find(params[:wisp_id])
  end
  
  def load_access_point
    @access_point = @wisp.access_points.find(params[:access_point_id])
  end
  
  # GET /wisps/:wisp_id/access_points/:access_point_id/l2tcs
  def index
    @l2tcs = @access_point.l2tcs

    respond_to do |format|
      format.html # index.html.erb
    end
  end
  
  def edit
    @l2tc = @access_point.l2tcs.find(params[:id])
  
    params[:shapeables] = {}
    params[:shapeables][:output_band] = @l2tc.shapeable.output_band
    params[:subinterfaces] = {}
    i = 0
    @l2tc.shapeable.subinterfaces.each do |s|
      params[:subinterfaces]["#{i}"] = {}
      params[:subinterfaces]["#{i}"][:output_band_percent] = s.output_band_percent
      i += 1
    end
    
  end

  def update
    @l2tc = @access_point.l2tcs.find(params[:id])

    result = true
    
    L2tcTemplate.transaction do
      @l2tc.shapeable.output_band = params[:shapeables][:output_band]
      if @l2tc.shapeable.save    
        i = 0
        @l2tc.shapeable.subinterfaces.each do |s|
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
      unless @l2tc.validate
        result = false
        raise ActiveRecord::Rollback
      end
    end
    
    respond_to do |format|
      if result and @l2tc.update_attributes(params[:l2tc])
        @access_point.update_configuration
        format.html { 
          redirect_to(wisp_access_point_l2tcs_url(@wisp, @access_point)) 
        }
      else
        format.html { render :action => "edit" }
      end
    end
  end
  
  def destroy
    @l2tc = @access_point.l2tcs.find(params[:id])
    @l2tc.shapeable.output_band = nil
    @l2tc.shapeable.subinterfaces.each do |s|
      s.output_band_percent = nil
      s.save!
    end
    @l2tc.shapeable.save!

    @access_point.update_configuration
    respond_to do |format|
      format.html { redirect_to(wisp_access_point_l2tcs_url(@wisp, @access_point)) }
    end
  end
  
end