class L2vpnClientsController < ApplicationController
  layout nil

  before_filter :load_wisp
  before_filter :load_access_point, :only => :index

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
    respond_to do |format|
      format.html do
        @access_point = @wisp.access_points.find(params[:access_point_id])
        @l2vpn = @access_point.l2vpn_clients.find(params[:id])
      end

      format.xml { render :xml => L2vpnClient.find_by_identifier(params[:id]).to_xml(:include => :access_point) }
    end
  end
end
