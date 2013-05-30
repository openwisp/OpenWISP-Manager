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

class L2tcsController < ApplicationController
  layout nil

  before_filter :load_wisp
  before_filter :load_access_point
    
  access_control do
    default :deny

    actions :index do
      allow :wisps_viewer
      allow :access_points_viewer, :of => :wisp
    end

    actions :edit, :update do
      allow :wisps_manager
      allow :access_points_manager, :of => :wisp
    end

    actions :destroy do
      allow :wisps_destroyer
      allow :access_points_destroyer, :of => :wisp
    end
  end

  # GET /wisps/:wisp_id/access_points/:access_point_id/l2tcs
  def index
    @l2tcs = @access_point.l2tcs

    respond_to do |format|
      format.html # index.html.erb
    end
  end
  
  def edit
    @l2tc = @access_point.l2tcs.find(params[:id])
  
    params[:shapeables] = {}
    params[:shapeables][:output_band] = @l2tc.shapeable.output_band
    params[:shapeables][:input_band] = @l2tc.shapeable.output_band
    params[:subinterfaces] = {}
    i = 0
    @l2tc.shapeable.subinterfaces.each do |s|
      params[:subinterfaces]["#{i}"] = {}
      params[:subinterfaces]["#{i}"][:output_band_percent] = s.output_band_percent
      params[:subinterfaces]["#{i}"][:input_band_percent] = s.input_band_percent
      i += 1
    end
    
  end

  def update
    @l2tc = @access_point.l2tcs.find(params[:id])

    L2tcTemplate.transaction do
      @l2tc.shapeable.output_band = params[:shapeables][:output_band]
      @l2tc.shapeable.input_band = params[:shapeables][:output_band]
      if @l2tc.shapeable.save    
        i = 0
        @l2tc.shapeable.subinterfaces.each do |s|
          s.output_band_percent = params[:subinterfaces]["#{i}"][:output_band_percent]
          s.input_band_percent = params[:subinterfaces]["#{i}"][:input_band_percent]
          unless s.save
            raise ActiveRecord::Rollback
          end
          i += 1
        end
      else
        raise ActiveRecord::Rollback
      end
      unless @l2tc.validate
        raise ActiveRecord::Rollback
      end
    end
    
    respond_to do |format|
      if @l2tc.update_attributes(params[:l2tc])
        format.html { 
          redirect_to(wisp_access_point_l2tcs_url(@wisp, @access_point)) 
        }
      else
        format.html { render :action => "edit" }
      end
    end
  end
  
  def destroy
    @l2tc = @access_point.l2tcs.find(params[:id])
    @l2tc.shapeable.output_band = nil
    @l2tc.shapeable.input_band = nil
    @l2tc.shapeable.subinterfaces.each do |s|
      s.output_band_percent = nil
      s.input_band_percent = nil
      s.save!
    end
    @l2tc.shapeable.save!

    respond_to do |format|
      format.html { redirect_to(wisp_access_point_l2tcs_url(@wisp, @access_point)) }
    end
  end
end