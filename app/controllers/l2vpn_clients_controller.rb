class L2vpnClientsController < ApplicationController
  layout nil

  before_filter :load_wisp
  before_filter :load_access_point
    
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
  
  def load_access_point
    @access_point = @wisp.access_points.find(params[:access_point_id])
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
