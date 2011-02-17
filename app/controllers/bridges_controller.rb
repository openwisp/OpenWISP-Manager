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
  end

  # GET /wisps/:wisp_id/access_points/:access_point_id/bridges
  def index
    @bridges = @access_point.bridges.find(:all)

    respond_to do |format|
      format.html # index.html.erb
    end
  end
end
