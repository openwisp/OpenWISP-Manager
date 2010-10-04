class RadiosController < ApplicationController
  layout nil
  
  before_filter :load_wisp
  before_filter :load_access_point

  access_control :subject_method => :current_operator do
    default :deny

    allow :admin
    allow :wisp_admin, :of => :wisp, :to => [ :index, :new, :edit, :create, :update, :destroy ]
    allow :wisp_operator, :of => :wisp, :to => [ :index, :new, :edit, :create, :update, :destroy ]
    allow :wisp_viewer, :of => :wisp, :to => [:index, :edit, :update ]
  end
  
  def load_wisp
    @wisp = Wisp.find(params[:wisp_id])
  end

  def load_access_point
    @access_point = @wisp.access_points.find(params[:access_point_id])
  end  
  
  # GET /wisps/:wisp_id/access_points/:access_point_id/radios/1/edit
  def edit
    @radio = @access_point.radios.find(params[:id])
  end
  
  def update
    @radio = @access_point.radios.find(params[:id])
    respond_to do |format|
      if @radio.update_attributes(params[:radio])
        # Update access_point Configuration
        @access_point.update_configuration
        format.html { redirect_to(wisp_access_point_radios_url(@wisp, @access_point)) }
      else
        format.html { render :action => "edit" }
      end
    end
  end
  
  def index
    @radios = @access_point.radios.find(:all)

    respond_to do |format|
      format.html # index.html.erb
    end
  end

end
