class BridgesController < ApplicationController
  layout nil

  before_filter :load_wisp
  before_filter :load_access_point
    
  access_control do
    default :deny

    actions :index do
      allow :wisps_viewer
      allow :access_points_viewer, :of => :wisp
    end

    #TODO: Update actions
    actions :edit, :update do
      allow :wisps_manager
      allow :access_points_manager, :of => :wisp
    end
  end

  def load_wisp
    @wisp = Wisp.find(params[:wisp_id])
  end

  def load_access_point
    @access_point = @wisp.access_points.find(params[:access_point_id])
  end

  # GET /wisps/:wisp_id/access_points/:access_point_id/bridges
  def index
    @bridges = @access_point.bridges.find(:all)
    
    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # TODO: Write edit action (route and view are defined but
  # the controller is missing)
  def edit
    render :nothing => true
  end

end
