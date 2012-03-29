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

class L2tcTemplatesController < ApplicationController
  layout nil

  before_filter :load_wisp
  before_filter :load_access_point_template

  access_control do
    default :deny

    actions :index, :show do
      allow :wisps_viewer
      allow :access_point_templates_viewer, :of => :wisp
    end

    actions :new, :create do
      allow :wisps_creator
      allow :access_point_templates_creator, :of => :wisp
    end

    actions :edit, :update do
      allow :wisps_manager
      allow :access_point_templates_manager, :of => :wisp
    end

    actions :destroy do
      allow :wisps_destroyer
      allow :access_point_templates_destroyer, :of => :wisp
    end
  end

  # GET /wisps/:wisp_id/access_point_templates/:access_point_template_id/l2tc_templates
  def index
    @l2tc_templates = @access_point_template.l2tc_templates

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def edit
    @l2tc_template = @access_point_template.l2tc_templates.find(params[:id])

    params[:shapeables] = {}
    params[:shapeables][:output_band] = @l2tc_template.shapeable_template.output_band
    params[:subinterfaces] = {}
    i = 0
    @l2tc_template.shapeable_template.subinterfaces.each do |s|
      params[:subinterfaces]["#{i}"] = {}
      params[:subinterfaces]["#{i}"][:output_band_percent] = s.output_band_percent
      i += 1
    end

  end

  def update
    @l2tc_template = @access_point_template.l2tc_templates.find(params[:id])

    result = true

    L2tcTemplate.transaction do
      @l2tc_template.shapeable_template.output_band = params[:shapeables][:output_band]
      if @l2tc_template.shapeable_template.save
        i = 0
        @l2tc_template.shapeable_template.subinterfaces.each do |s|
          s.output_band_percent = params[:subinterfaces]["#{i}"][:output_band_percent]
          unless s.save
            result = false
            raise ActiveRecord::Rollback
          end
          i += 1
        end
      else
        result = false
        raise ActiveRecord::Rollback
      end
      unless @l2tc_template.validate
        result = false
        raise ActiveRecord::Rollback
      end
    end

    respond_to do |format|
      if result and @l2tc_template.update_attributes(params[:l2tc_template])
        format.html {
          redirect_to(wisp_access_point_template_l2tc_templates_url(@wisp, @access_point_template))
        }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  def destroy
    @l2tc_template = @access_point_template.l2tc_templates.find(params[:id])
    @l2tc_template.shapeable_template.output_band = nil
    @l2tc_template.shapeable_template.subinterfaces.each do |s|
      s.output_band_percent = nil
      s.save!
    end
    @l2tc_template.shapeable_template.save!

    respond_to do |format|
      format.html { redirect_to(wisp_access_point_template_l2tc_templates_url(@wisp, @access_point_template)) }
    end
  end
end