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

class AccessPointGroupsController < ApplicationController
  before_filter :load_wisp
  before_filter :load_access_point_group, :except => [ :index, :new, :create ]

  access_control do
    default :deny

    actions :index, :show do
      allow :wisps_viewer
      allow :access_point_groups_viewer, :of => :wisp
    end

    actions :new, :create do
      allow :wisps_creator
      allow :access_point_groups_creator, :of => :wisp
    end

    actions :edit, :update do
      allow :wisps_manager
      allow :access_point_groups_manager, :of => :wisp
    end

    actions :destroy do
      allow :wisps_destroyer
      allow :access_points_groups_destroyer, :of => :wisp
    end
  end

  # GET /wisps/:wisp_id/access_point_groups
  def index
    @access_point_groups = @wisp.access_point_groups

    respond_to do |format|
      format.html # index.html.erb
      format.xml { render :xml => @access_point_groups }
    end
  end

  # GET /wisps/:wisp_id/access_point_groups/1
  def show

    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # GET /wisps/:wisp_id/access_point_groups/new
  def new
    @access_point_group = @wisp.access_point_groups.new
    @selected_access_points = []

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /wisps/:wisp_id/access_point_groups/1/edit
  def edit
    @selected_access_points = @access_point_group.access_points.collect { |h| h.id }
  end

  # POST /wisps/:wisp_id/access_point_groups
  def create
    @access_point_group = @wisp.access_point_groups.new(params[:access_point_group])

    @selected_access_points = params[:access_points].nil? ? nil : params[:access_points].collect { |h| h.to_i }

    @access_point_group.access_points = []
    unless params[:access_points].nil?
      params[:access_points].each { |hid|
        @access_point_group.access_points << @wisp.access_points.find(hid)
      }
    end

    respond_to do |format|
      if @access_point_group.save
        flash[:notice] = t(:AccessPointGroup_was_successfully_created)
        format.html { redirect_to(wisp_access_point_group_url(@wisp, @access_point_group)) }
        # Starts an async job for ap configuration creation
        worker = MiddleMan.worker(:configuration_worker)
        worker.async_update_redis_ap_info_by_group(
          :arg => { :access_point_group_id => [ @access_point_group.id ], :method => "insert" }
        )
      else
        format.html { render :action => "new" }
      end
    end
  end

  # PUT /wisps/:wisp_id/access_point_groups/1
  def update
    @selected_access_points = params[:access_points].nil? ? nil : params[:access_points].collect { |h| h.to_i }

    @access_point_group.access_points = []
    unless params[:access_points].nil?
      params[:access_points].each { |hid|
        @access_point_group.access_points << @wisp.access_points.find(hid)
      }
    end

    respond_to do |format|
      if @access_point_group.update_attributes(params[:access_point_group])
        flash[:notice] = t(:AccessPointGroup_was_successfully_updated)
        format.html { redirect_to(wisp_access_point_group_url(@wisp, @access_point_group)) }
        worker = MiddleMan.worker(:configuration_worker)
        worker.async_update_redis_ap_info_by_group(
          :arg => { :access_point_group_id => [ @access_point_group.id ] , :method => "insert"}
        )
      else
        format.html { render :action => "edit" }
      end
    end
  end

  # DELETE /wisps/:wisp_id/access_point_groups/1
  def destroy
    @access_point_group.remove_from_redis_info
    @access_point_group.destroy
    respond_to do |format|
      format.html { redirect_to(wisp_access_point_groups_url) }
    end
  end

  private

  def load_access_point_group
    @access_point_group = @wisp.access_point_groups.find(params[:id])
  end
end
