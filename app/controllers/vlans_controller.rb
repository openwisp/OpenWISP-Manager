class VlansController < ApplicationController
  layout nil

  before_filter :load_wisp
  before_filter :load_access_point
  
  access_control :subject_method => :current_operator do
    default :deny

    allow :admin
    allow :wisp_admin, :of => :wisp, :to => [ :index, :new, :create, :destroy]
    allow :wisp_operator, :of => :wisp, :to => [ :index, :new, :create, :destroy]
    allow :wisp_viewer, :of => :wisp, :to => [ :index ]
  end

  def load_wisp
    @wisp = Wisp.find(params[:wisp_id])
  end
  
  def load_access_point
    @access_point = @wisp.access_points.find(params[:access_point_id])
  end
  
  def index
    @devices = @access_point.interfaces
    
    respond_to do |format|
      format.html # index.html.erb
    end
  end

end
