# This file is part of the OpenWISP Manager
#
# Copyright (C) 2012 OpenWISP.org
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

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

  private
  
  def load_server
    @server = Server.find(params[:id])
  end
end
