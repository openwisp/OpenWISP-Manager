# This file is part of the OpenWISP Manager
#
# Copyright (C) 2010 CASPUR (wifi@caspur.it)
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

class TemplateGroupsController < ApplicationController
  before_filter :load_wisp
  before_filter :load_template_group, :except => [ :index, :new, :create ]

  access_control do
    default :deny
  end

  # GET /wisps/:wisp_id/template_groups
  def index
    @template_groups = @wisp.template_groups

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /wisps/:wisp_id/template_groups/1
  def show
    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # GET /wisps/:wisp_id/template_groups/new
  def new
    @template_group = @wisp.template_groups.new
    @selected_access_point_templates = []

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /wisps/:wisp_id/template_groups/1/edit
  def edit
    @selected_access_point_templates = @template_group.access_point_templates.collect { |h| h.id }
  end

  # POST /wisps/:wisp_id/template_groups
  def create
    @template_group = @wisp.template_groups.new(params[:template_group])

    @selected_access_point_templates = params[:access_point_templates].nil? ? nil : params[:access_point_templates].collect { |h| h.to_i }

    @template_group.access_point_templates = []
    unless params[:access_point_templates].nil?
      params[:access_point_templates].each { |hid|
        @template_group.access_point_templates << @wisp.access_point_templates.find(hid)
      }
    end

    respond_to do |format|
      if @template_group.save
        flash[:notice] = t(:TemplateGroup_was_successfully_created)
        format.html { redirect_to(wisp_template_groups_url(@wisp)) }
      else
        format.html { render :action => "new" }
      end
    end
  end

  # PUT /wisps/:wisp_id/template_groups/1
  def update
    @selected_access_point_templates = params[:access_point_templates].nil? ? nil : params[:access_point_templates].collect { |h| h.to_i }

    @template_group.access_point_templates = []
    unless params[:access_point_templates].nil?
      params[:access_point_templates].each { |hid|
        @template_group.access_point_templates << @wisp.access_point_templates.find(hid)
      }
    end

    respond_to do |format|
      if @template_group.update_attributes(params[:template_group])
        flash[:notice] = t(:TemplateGroup_was_successfully_updated)
        format.html { redirect_to(wisp_template_groups_url(@wisp)) }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  # DELETE /wisps/:wisp_id/template_groups/1
  def destroy
    @template_group.destroy

    respond_to do |format|
      format.html { redirect_to(wisp_template_groups_url(@wisp)) }
    end
  end

  private

  def load_template_group
    @template_group = @wisp.template_groups.find(params[:id])
  end
end
