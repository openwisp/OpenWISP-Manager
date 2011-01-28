class ServersController < ApplicationController
  before_filter :load_server, :except => [ :index, :new, :create, :ajax_stats ]
  
  access_control do
    default :deny

    actions :index, :show, :ajax_stats do
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
    @server = Server.find(params[:id])
  end

  # GET /servers
  def index
    @servers = Server.all
    
    respond_to do |format|
      format.html # index.html.erb
    end
  end
  
  def new
    @server = Server.new
  end
  
  
  
  def edit
    
  end

  def create
    @server = Server.new(params[:server])
    
    if @server.save
      respond_to do |format|
          flash[:notice] = t(:Server_created)
          format.html { redirect_to(servers_url) }
      end
    else
      respond_to do |format|
        format.html { render :action => "new" }
      end
    end
  end
  
  def update
    if @server.update_attributes(params[:server])
      respond_to do |format|
          flash[:notice] = t(:Server_updated)
          format.html { redirect_to(servers_url) }
      end
    else
      respond_to do |format|
        format.html { render :action => "edit" }
      end
    end
  end
  
  def destroy
    @server.destroy
        
    respond_to do |format|
      format.html { redirect_to(servers_url) }
    end
  end

  # Ajax Methods
  def ajax_stats
    @server = Server.find(params[:id])
    
    respond_to do |format|
      format.html { render :partial => "stats", :object => @server }
    end
  end

end
