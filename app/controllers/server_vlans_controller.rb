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

class ServerVlansController < ApplicationController
  layout nil

  before_filter :load_server
  before_filter :load_vlan, :except => [ :index, :new, :create ]
  
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

  def index
    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def new
    @devices = @server.interfaces
    @taps = @server.taps
    @ethernets = @server.ethernets

    @interface_select = @taps.map { |t| [ t.friendly_name, "#{t.id}_tap" ] }
    @interface_select.concat(@ethernets.map { |e| [ e.friendly_name, "#{e.id}_ethernet" ] })
    @interface_select_selected = []
 
    @vlan = Vlan.new()

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  def create
    @taps = @server.taps
    @ethernets = @server.ethernets

    @interface_select = @taps.map { |t| [ t.friendly_name, "#{t.id}_tap" ] }
    @interface_select.concat(@ethernets.map { |e| [ e.friendly_name, "#{e.id}_ethernet" ] })

    unless params[:interface_select].nil?
      @idt = params[:interface_select].split('_')
      if @idt[1] == 'tap'
        interface = @taps.find(@idt[0])
      elsif @idt[1] == 'ethernet'
        interface = @ethernets.find(@idt[0])
      end
      @vlan = interface.vlans.build(params[:vlan])
    end

    respond_to do |format|
      if @vlan.save
        format.html { 
          redirect_to(server_vlans_url(@server)) 
        }
      else
        format.html { render :action => "new" }
      end
    end
    
  end

  def destroy
    @vlan = Vlan.find(params[:id])
    @vlan.destroy
    
    respond_to do |format|
      format.html { redirect_to(server_vlans_url(@server)) }
    end
  end

  private

  def load_vlan
    @vlan = @server.vlans
  end
end
