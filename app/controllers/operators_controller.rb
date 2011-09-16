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

class OperatorsController < ApplicationController
  before_filter :load_wisp, :except => [:show]

  access_control do
    default :deny

    actions :index do
      allow :wisps_viewer
      allow :operators_viewer, :of => :wisp
    end
    allow logged_in, :to => :show

    actions :new, :create do
      allow :wisps_creator
      allow :operators_creator, :of => :wisp
    end

    actions :edit, :update do
      allow :wisps_manager
      allow :operators_manager, :of => :wisp
    end

    actions :destroy do
      allow :wisps_destroyer
      allow :operators_destroyer, :of => :wisp
    end
  end

  def index
    @operators = @wisp.operators
  end

  def show
    @operator = Operator.find(params[:id])
    load_wisp if params[:wisp_id]
    
    if current_operator != @operator
      #TODO: implement stats for :operator_viewer
      redirect_to :back
    end
  end

  def new
    @operator = @wisp.operators.build
    @selected_roles = []
  end

  def edit
    @operator = @wisp.operators.find(params[:id])
    # subject.roles won't work!
    @selected_roles = @operator.roles
  end

  def create
    @operator = @wisp.operators.build(params[:operator])

    @selected_roles = (params[:roles].nil? || params[:roles].length == 0) ? [] : params[:roles]

    if @operator.save
      @operator.roles = @selected_roles

      respond_to do |format|
        flash[:notice] = t(:Account_registered)
        format.html { redirect_to(wisp_operators_url) }
      end
    else
      respond_to do |format|
        format.html { render :action => "new" }
      end
    end
  end

  def update
    @operator = @wisp.operators.find(params[:id])

    @selected_roles = (params[:roles].nil? || params[:roles].length == 0) ? [] : params[:roles]

    if @operator.update_attributes(params[:operator])
      @operator.roles = @selected_roles

      respond_to do |format|
        flash[:notice] = t(:Account_updated)
        format.html { redirect_to(wisp_operators_url(@wisp)) }
      end
    else
      respond_to do |format|
        format.html { render :action => "edit" }
      end
    end
  end

  def destroy
    @operator = @wisp.operators.find(params[:id])
    @operator.has_no_roles!
    @operator.destroy

    respond_to do |format|
      format.html { redirect_to(wisp_operators_url(@wisp)) }
    end
  end
end
