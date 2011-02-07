class VlansController < ApplicationController
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

  def index
    @devices = @access_point.interfaces

    respond_to do |format|
      format.html # index.html.erb
    end
  end
end
