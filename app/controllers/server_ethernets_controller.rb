class ServerEthernetsController < ApplicationController
  layout nil

  before_filter :load_server
  before_filter :load_ethernet, :except => [ :index, :new, :create ]

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

  def load_server
    @server = Server.find(params[:server_id])
  end
  
  def load_ethernet
    @ethernet = @server.ethernets.find(params[:id]) 
  end

  def index
    @ethernets = @server.ethernets

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def show

    respond_to do |format|
      format.html # show.html.erb
    end
  end

  def new
    @ethernet = Ethernet.new()

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  def edit
    
  end

  def create
    @ethernet = @server.ethernets.new(params[:ethernet])
    
    respond_to do |format|
      if @ethernet.save
        #flash[:notice] = 'Ethernet NIC was successfully created.'
        format.html { redirect_to(server_ethernets_url(@server)) }
      else
        format.html { render :action => "new" }
      end
    end
  end

  def update

    respond_to do |format|
      if @ethernet.update_attributes(params[:ethernet])
        format.html { redirect_to(server_ethernets_url(@server)) }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  def destroy
    @ethernet.destroy

    respond_to do |format|
      format.html { redirect_to(server_ethernets_url(@server)) }
    end
  end
    
end
