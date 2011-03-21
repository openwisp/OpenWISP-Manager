class L2vpnServersController < ApplicationController
  layout nil

  before_filter :load_server
  before_filter :load_l2vpn_server, :except => [ :index, :new, :create ]
  before_filter :load_wisps, :except => [ :index, :show, :destroy ]
  before_filter :load_server_ip, :only => [ :new, :create, :edit ]

  access_control do
    default :deny

    actions :index, :show do
      allow :servers_viewer
    end

    actions :new, :create do
      allow :servers_creator
    end

    actions :edit, :update do
      allow :servers_manager
    end

    actions :destroy do
      allow :servers_destroyer
    end
  end

  def index
    @l2vpn_servers = @server.l2vpn_servers
  end

  def show
  end

  def new
    @l2vpn_server = L2vpnServer.new( :wisp => Wisp.last )
  end

  def edit
  end

  def create
    @l2vpn_server = @server.l2vpn_servers.build(params[:l2vpn_server])
    @l2vpn_server.tap = Tap.new

    if @l2vpn_server.save
      @l2vpn_server.tap.save!

      # Create DH and TLS auth key and generate tar.gz configuration
      worker = MiddleMan.worker(:configuration_worker)
      worker.async_create_l2vpn_server_configuration(
          :arg => { :l2vpn_server_id => @l2vpn_server.id }
      )

      respond_to do |format|
        flash[:notice] = t(:L2vpn_server_created)
        format.html { redirect_to(server_l2vpn_servers_url(@server)) }
      end
    else
      respond_to do |format|
        format.html { render :action => "new" }
      end
    end
  end

  def update
    if @l2vpn_server.update_attributes(params[:l2vpn_server])
      respond_to do |format|
        flash[:notice] = t(:L2vpn_server_updated)
        format.html { redirect_to(server_l2vpn_servers_url(@server)) }
      end
    else
      respond_to do |format|
        format.html { render :action => "edit" }
      end
    end
  end

  def destroy
    worker = MiddleMan.worker(:configuration_worker)
    worker.async_delete_l2vpn_server_configuration(
        :arg => { :l2vpn_server_id => @l2vpn_server.id }
    )

    @l2vpn_server.destroy

    respond_to do |format|
      format.html { redirect_to(server_l2vpn_servers_url(@server)) }
    end
  end

  private

  def load_server_ip
    @server_ip = []
    @server.bridges.each do |b|
      if b.addressing_mode == "static"
        @server_ip << b.ip
      end
    end
    @server_ip << "all"
  end

  def load_l2vpn_server
    @l2vpn_server = @server.l2vpn_servers.find(params[:id])
  end
end
