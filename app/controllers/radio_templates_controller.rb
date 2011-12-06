# This file is part of the OpenWISP Manager
#
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

class RadioTemplatesController < ApplicationController
  layout nil

  before_filter :load_wisp, :except => [:modes_for_driver, :channels_for_mode]
  before_filter :load_access_point_template, :except => [:modes_for_driver, :channels_for_mode]

  access_control do
    default :deny

    actions :index, :show do
      allow :wisps_viewer
      allow :access_point_templates_viewer, :of => :wisp
    end

    actions :new, :create, :modes_for_driver, :channels_for_mode do
      allow :wisps_creator
      allow :access_point_templates_creator, :of => :wisp
    end

    actions :edit, :update, :modes_for_driver, :channels_for_mode do
      allow :wisps_manager
      allow :access_point_templates_manager, :of => :wisp
    end

    actions :destroy do
      allow :wisps_destroyer
      allow :access_point_templates_destroyer, :of => :wisp
    end
  end

  # GET /wisps/:wisp_id/access_point_templates/:access_point_template_id/radio_templates
  def index
    @radio_templates = @access_point_template.radio_templates.find(:all)

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /wisps/:wisp_id/access_points/:access_point_template_id/radios/1
  def show
    @radio_template = @access_point_template.radio_templates.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # GET /wisps/:wisp_id/access_points/:access_point_template_id/radios/new
  def new
    selected_driver = RadioTemplate::DRIVERS.first
    selected_mode = RadioTemplate.modes_for_driver(selected_driver).first
    selected_channel =  RadioTemplate.channels_for_mode(selected_mode)

    @radio_template = @access_point_template.radio_templates.build(
        :driver => selected_driver,
        :mode => selected_mode,
        :channel => selected_channel
    )
    RadioTemplate::MAX_VAPS.times { @radio_template.vap_templates.build() }

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /wisps/:wisp_id/access_points/:access_point_template_id/radios/1/edit
  def edit
    @radio_template = @access_point_template.radio_templates.find(params[:id])
    (RadioTemplate::MAX_VAPS - @radio_template.vap_templates.length).times { @radio_template.vap_templates.build }
  end

  # POST /wisps/:wisp_id/access_points/:access_point_template_id/radios
  def create
    @radio_template = @access_point_template.radio_templates.build(params[:radio_template])

    respond_to do |format|
      if @radio_template.save
        #flash[:notice] = 'Radio was successfully created.'
        format.html { redirect_to(wisp_access_point_template_radio_templates_url(@wisp, @access_point_template)) }
      else
        format.html { render :action => "new" }
      end
    end
  end

  # PUT /wisps/:wisp_id/access_points/:access_point_template_id/radios/1
  def update
    @radio_template = @access_point_template.radio_templates.find(params[:id])
    respond_to do |format|
      if @radio_template.update_attributes(params[:radio_template])
        #flash[:notice] = 'Radio was successfully updated.'
        format.html { redirect_to(wisp_access_point_template_radio_templates_url(@wisp, @access_point_template)) }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  # DELETE /wisps/:wisp_id/access_points/:access_point_template_id/radios/1
  def destroy
    @radio_template = @access_point_template.radio_templates.find(params[:id])
    @radio_template.destroy

    respond_to do |format|
      format.html { redirect_to(wisp_access_point_template_radio_templates_url(@wisp, @access_point_template)) }
    end
  end

  # Ajax actions
  def modes_for_driver
    modes = RadioTemplate.modes_for_driver(params[:driver])
    respond_to do |format|
      format.html {
        render :partial => 'modes_select_box', :locals => {
            :modes => modes,
            :form_object => RadioTemplate.new,
            :selected_mode => modes.first
        }
      }
    end
  end

  def channels_for_mode
    channels = RadioTemplate.channels_for_mode(params[:mode])
    respond_to do |format|
      format.html {
        render :partial => 'channels_select_box', :locals => {
            :channels => channels,
            :form_object => RadioTemplate.new,
            :selected_channel => channels.first.to_s
        }
      }
    end
  end

end
