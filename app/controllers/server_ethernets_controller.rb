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

  private

  def load_ethernet
    @ethernet = @server.ethernets.find(params[:id])
  end
end
