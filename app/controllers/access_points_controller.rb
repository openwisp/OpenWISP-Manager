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

class AccessPointsController < ApplicationController
  include Addons::Mappable

  before_filter :load_wisp, :except => [:get_configuration, :get_configuration_md5]
  skip_before_filter :require_operator, :only => [:get_configuration, :get_configuration_md5]
  before_filter :require_no_operator, :only => [:get_configuration, :get_configuration_md5]

  access_control do
    default :deny

    actions :index, :show, :outdated do
      allow :wisps_viewer
      allow :access_points_viewer, :of => :wisp
    end

    actions :new, :create do
      allow :wisps_creator
      allow :access_points_creator, :of => :wisp
    end

    actions :edit, :update, :update_outdated do
      allow :wisps_manager
      allow :access_points_manager, :of => :wisp
    end

    actions :destroy do
      allow :wisps_destroyer
      allow :access_points_destroyer, :of => :wisp
    end

    allow all, :to => [:get_configuration, :get_configuration_md5]
  end

  def get_configuration
    mac_address = params[:mac_address]
    if mac_address =~ /\A([0-9a-fA-F][0-9a-fA-F]:){5}[0-9a-fA-F][0-9a-fA-F]\Z/
      mac_address.downcase!
      access_point = AccessPoint.find_by_mac_address(mac_address)

      #Updating configuration files if old
      if !access_point.nil?
        access_point.last_seen_on request.remote_ip

        #Sending configuration files for the access point
        send_file ACCESS_POINTS_CONFIGURATION_PATH.join(
                      "ap-#{access_point.wisp.id}-#{access_point.id}.tar.gz"
                  )
      else
        send_file "public/404.html", :status => 404
      end
    else
      send_file "public/404.html", :status => 404
    end

  end

  def get_configuration_md5
    mac_address = params[:mac_address]

    if mac_address =~ /\A([0-9a-fA-F][0-9a-fA-F]:){5}[0-9a-fA-F][0-9a-fA-F]\Z/
      mac_address.downcase!
      access_point = AccessPoint.find_by_mac_address(mac_address)

      if !access_point.nil?
        access_point.last_seen_on request.remote_ip

        if !access_point.configuration_md5.nil?
          #Sending md5 digest of configuration files
          send_data access_point.configuration_md5
        end
      else
        send_file "public/404.html", :status => 404
      end
    else
      send_file "public/404.html", :status => 404
    end

  end

  # GET /wisps/:wisp_id/access_points
  def index
    @access_points = @wisp.access_points

    respond_to do |format|
      format.html # index.html.erb
      format.json
      format.xml { render :xml => @access_points }
    end
  end

  # GET /wisps/:wisp_id/access_points/1
  def show
    respond_to do |format|
      format.html { @access_point = @wisp.access_points.find(params[:id]) }

      format.xml do
        @access_point = @wisp.access_points.find_by_name(params[:id])

        if @access_point.nil?
          @access_point = AccessPoint.find_by_common_name(params[:id])

          # Enforce access control on wisp for access point
          @access_point = nil if @access_point.wisp != @wisp
        end

        render :xml => @access_point
      end
    end
  end

  # GET /wisps/:wisp_id/access_points/new
  def new
    @access_point = AccessPoint.new

    @access_point_templates = @wisp.access_point_templates
    @selected_access_point_template = nil

    @latlon = @wisp.geocode

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /wisps/:wisp_id/access_points/1/edit
  def edit
    @access_point = @wisp.access_points.find(params[:id])

    @access_point_templates = @wisp.access_point_templates
    @selected_access_point_template = !@access_point.access_point_template.nil? ? @access_point.access_point_template.id.to_s : nil
  end

  # POST /wisps/:wisp_id/access_points
  def create
    @access_point = @wisp.access_points.build(params[:access_point])

    @access_point_templates = @wisp.access_point_templates
    @selected_access_point_template = params[:access_point_template][:id]

    unless @selected_access_point_template.blank? or @selected_access_point_template.nil?
      @access_point_template = @access_point_templates.find(@selected_access_point_template)
    else
      @access_point_template = nil
    end

    save_success = true
    AccessPoint.transaction do
      # We have to generate access_point.id to permit templates instantiations (access_point.id)

      if @access_point.save

        unless @access_point_template.nil?
          unless @access_point.link_to_template(@access_point_template)
            raise ActiveRecord::Rollback
          end
        end
      else
        save_success = false
      end
    end

    if save_success
      # Starts an async job for ap configuration creation
      worker = MiddleMan.worker(:configuration_worker)
      worker.async_create_access_points_configuration(
          :arg => { :access_point_ids => [ @access_point.id ] }
      )

      respond_to do |format|
        flash[:notice] = t(:AccessPoint_was_successfully_created)
        format.html { redirect_to(wisp_access_point_url(@wisp, @access_point)) }
      end
    else
      @latlon = [params[:access_point][:lat], params[:access_point][:lon]]

      if save_success
        @access_point.destroy()
        @access_point = @wisp.access_points.build(params[:access_point])
      end

      respond_to do |format|
        format.html { render :action => "new" }
      end
    end
  end

  # PUT /wisps/:wisp_id/access_points/1
  def update
    @access_point = @wisp.access_points.find(params[:id])

    @access_point_templates = @wisp.access_point_templates

    if @access_point.update_attributes(params[:access_point])
      respond_to do |format|
        flash[:notice] = t(:AccessPoint_was_successfully_updated)
        format.html { redirect_to(wisp_access_point_url(@wisp, @access_point)) }
      end
    else
      @hselected_access_point_template = @access_point.access_point_template.id.to_s

      respond_to do |format|
        format.html { render :action => "edit" }
      end
    end
  end

  # DELETE /wisps/:wisp_id/access_points/1
  def destroy
    @access_point = @wisp.access_points.find(params[:id])

    worker = MiddleMan.worker(:configuration_worker)
    worker.async_delete_access_points_configuration(
        :arg => { :access_point_ids => [ @access_point.id ] }
    )

    @access_point.destroy

    respond_to do |format|
      format.html { redirect_to(wisp_access_points_url(@wisp)) }
    end
  end

  def outdated
    @access_points = @wisp.access_points.select {|ap| ap.configuration_outdated? }
  end

  def update_outdated
    # TODO: some ajax-magic is needed here...
    access_points = params[:id] ? [@wisp.access_points.find(params[:id])] : @wisp.access_points.select {|ap| ap.configuration_outdated? }

    worker = MiddleMan.worker(:configuration_worker)
    worker.async_create_access_points_configuration(:arg => { :access_point_ids => access_points.map{ |ap| ap.id } })

    redirect_to wisp_access_points_url(@wisp)
  end
end
