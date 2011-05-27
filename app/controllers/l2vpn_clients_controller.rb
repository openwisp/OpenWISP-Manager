class L2vpnClientsController < ApplicationController
  layout nil

  before_filter :load_wisp
  before_filter :load_access_point

  access_control do
    default :deny

    actions :index, :show do
      allow :wisps_viewer
      allow :access_points_viewer, :of => :wisp
    end
  end

  # GET /wisps/:wisp_id/access_points/:access_point_id/l2vpn_clients
  def index
    @l2vpn_clients = @access_point.l2vpn_clients.find(:all)

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /wisps/:wisp_id/access_points/:access_point_id/l2vpn_clients/1
  def show
    @l2vpn = @access_point.l2vpn_clients.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
    end
  end
end
