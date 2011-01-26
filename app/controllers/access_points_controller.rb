class AccessPointsController < ApplicationController
  include MappablesAddons

  before_filter :load_wisp, :except => [:ajax_update_gmap, :get_configuration, :get_configuration_md5]
  before_filter :load_access_point, :except => [:index, :new, :create, :ajax_update_gmap, :get_configuration, :get_configuration_md5, :outdated_access_points_update]

  access_control :subject_method => :current_operator do
    default :deny

    allow :admin
    allow :wisp_admin, :of => :wisp, :to => [:index, :show, :new, :edit, :create, :update, :destroy, :ajax_update_gmap]
    allow :wisp_operator, :of => :wisp, :to => [:show, :index, :new, :edit, :update, :ajax_update_gmap]
    allow :wisp_viewer, :of => :wisp, :to => [:show, :index]
    allow anonymous, :to => [:get_configuration, :get_configuration_md5]
  end

  def load_wisp
    @wisp = Wisp.find(params[:wisp_id])
  end

  def load_access_point
    @access_point = @wisp.access_points.find(params[:id])
  end

  def get_configuration

    mac_address = params[:mac_address]
    remote_ip_address = request.remote_ip
    if mac_address =~ /\A([0-9a-fA-F][0-9a-fA-F]:){5}[0-9a-fA-F][0-9a-fA-F]\Z/

      mac_address.downcase!

      access_point = AccessPoint.find_by_mac_address(mac_address)

      #Updating configuration files if old
      if !access_point.nil?
        if access_point.last_configuration_retrieve_ip != remote_ip_address
          access_point.update_attributes(:last_configuration_retrieve_ip => remote_ip_address)
        end
        #Sending configuration files for the access point
        send_file "#{RAILS_ROOT}/private/access_points_configurations/ap-#{access_point.wisp.id}-#{access_point.id}.tar.gz"
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
    @access_point_templates = @wisp.access_point_templates

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /wisps/:wisp_id/access_points/1
  def show

    @map_variable = "map_new"
    @marker_variable = "marker_new"
    @div_variable = "div_new"
    @latlon =  [@access_point.lat, @access_point.lon]
    @zoom = 16

    @map = GMap.new(@div_variable, @map_variable)
    @map.control_init(:large_map => true, :map_type => true)
    @map.set_map_type_init(GMapType::G_NORMAL_MAP)
    @map.center_zoom_init(@latlon, @zoom)
    info = <<ENI
<table>
<tr>
  <td><b>#{t(:Name)}</b></td>
  <td>#{@access_point.name}</td>
</tr>
  <td><b>#{t(:Address)}</b></td>
  <td>#{@access_point.address}</td>
</tr>
  <td><b>#{t(:City)}</b></td>
  <td>#{@access_point.city}</td>
</tr>
</table>
ENI
    @marker = GMarker.new(@latlon, :title => @access_point.name, :draggable => false, :info_window => info )
    @map.overlay_global_init(@marker, @marker_variable)

    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # GET /wisps/:wisp_id/access_points/new
  def new
    @access_point = AccessPoint.new()

    @access_point_groups = @wisp.access_point_groups
    @selected_access_point_groups = []
    @access_point_templates = @wisp.access_point_templates
    @selected_access_point_template = nil

    @map_variable = "map_new"
    @marker_variable = "marker_new"
    @div_variable = "div_new"
    #@latlon = [41.9, 12.4833]
    #@zoom = 10
    llz = get_center_zoom(@wisp.access_points)
    @latlon = llz[0,2]
    @zoom = llz[2]

    @map = GMap.new(@div_variable, @map_variable)
    @map.control_init(:large_map => true,:map_type => true)
    @map.set_map_type_init(GMapType::G_HYBRID_MAP)
    @map.center_zoom_init(@latlon, @zoom)
    @marker = GMarker.new(@latlon, :title => t(:Select_location), :draggable => true )
    @map.overlay_global_init(@marker,@marker_variable)
    @map.record_init @marker.on_dragend("gmap_update_position")

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /wisps/:wisp_id/access_points/1/edit
  def edit
    @access_point_groups = @wisp.access_point_groups
    @selected_access_point_groups = @access_point.access_point_groups.map { |g| g.id.to_s }
    @access_point_templates = @wisp.access_point_templates
    @selected_access_point_template = !@access_point.access_point_template.nil? ? @access_point.access_point_template.id.to_s : nil

    @map_variable = "map_new"
    @marker_variable = "marker_new"
    @div_variable = "div_new"
    @latlon = [@access_point[:lat], @access_point[:lon]]
    @zoom = 14

    @map = GMap.new(@div_variable, @map_variable)
    @map.control_init(:large_map => true,:map_type => true)
    @map.set_map_type_init(GMapType::G_HYBRID_MAP)
    @map.center_zoom_init(@latlon, @zoom)
    @marker = GMarker.new(@latlon, :title => t(:Select_location), :draggable => true )
    @map.overlay_global_init(@marker,@marker_variable)
    @map.record_init @marker.on_dragend("gmap_update_position")

  end

  # POST /wisps/:wisp_id/access_points
  def create
    @access_point = @wisp.access_points.build(params[:access_point])

    # MAC Address in lowercase 
    @access_point.mac_address.downcase!

    @access_point_groups = @wisp.access_point_groups
    if params[:access_point_groups].nil?
      @selected_access_point_groups = []
    else
      @selected_access_point_groups = params[:access_point_groups]
    end

    @access_point_templates = @wisp.access_point_templates
    @selected_access_point_template = params[:access_point_template][:id]

    @selected_access_point_groups.each do |gid|
      @access_point.access_point_groups << @access_point_groups.find(gid)
    end

    unless @selected_access_point_template.blank? or @selected_access_point_template.nil?
      @access_point_template = @access_point_templates.find(@selected_access_point_template)
    else
      @access_point_template = nil
    end

    save_success = true
    link_success = true
    AccessPoint.transaction do
      # We have to generate access_point.id to permit templates instantiations (access_point.id)

      if @access_point.save

        unless @access_point_template.nil?
          unless @access_point.link_to_template(@access_point_template)
            link_success = false
            raise ActiveRecord::Rollback
          end
        end
        #Generation of the configuration files for the Access Point just saved
        @access_point.generate_configuration
        #Generation of md5 digest for new configuration
        @access_point.generate_configuration_md5
        @access_point.touch(:committed_at)
      else
        save_success = false
      end
    end

    if save_success and link_success
      respond_to do |format|
        flash[:notice] = t(:AccessPoint_was_successfully_created)
        format.html { redirect_to(wisp_access_point_url(@wisp, @access_point)) }
      end
    else
      @map_variable = "map_new"
      @marker_variable = "marker_new"
      @div_variable = "div_new"
      @latlon = [params[:access_point][:lat], params[:access_point][:lon]]
      @zoom = 14

      @map = GMap.new(@div_variable, @map_variable)
      @map.control_init(:large_map => true,:map_type => true)
      @map.set_map_type_init(GMapType::G_HYBRID_MAP)
      @map.center_zoom_init(@latlon, @zoom)
      @marker = GMarker.new(@latlon, :title => t(:Select_location), :draggable => true )
      @map.overlay_global_init(@marker,@marker_variable)
      @map.record_init @marker.on_dragend("gmap_update_position")

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
    @access_point_templates = @wisp.access_point_templates
    @access_point_groups = @wisp.access_point_groups
    if params[:access_point_groups].nil?
      @selected_access_point_groups = []
    else
      @selected_access_point_groups = params[:access_point_groups]
    end

    @access_point.access_point_groups = []
    @selected_access_point_groups.each do |gid|
      @access_point.access_point_groups << @access_point_groups.find(gid)
    end

    if @access_point.update_attributes(params[:access_point])

      # Delete old Configuration
      @conf_fileName = "#{RAILS_ROOT}/private/access_points_configurations/ap-#{@access_point.wisp.id}-#{@access_point.id}.tar.gz"
      File.delete(@conf_fileName)

      # Updating of the configuration files for the Access Point just edited
      @access_point.generate_configuration

      # Generation of md5 digest for new configuration
      @access_point.generate_configuration_md5
      @access_point.touch(:committed_at)

      respond_to do |format|
        flash[:notice] = t(:AccessPoint_was_successfully_updated)
        format.html { redirect_to(wisp_access_point_url(@wisp, @access_point)) }
      end
    else
      @hselected_access_point_template = @access_point.access_point_template.id.to_s

      @map_variable = "map_new"
      @marker_variable = "marker_new"
      @div_variable = "div_new"
      @latlon = [params[:access_point][:lat], params[:access_point][:lon]]
      @zoom = 14

      @map = GMap.new(@div_variable, @map_variable)
      @map.control_init(:large_map => true,:map_type => true)
      @map.set_map_type_init(GMapType::G_HYBRID_MAP)
      @map.center_zoom_init(@latlon, @zoom)
      @marker = GMarker.new(@latlon, :title => t(:Select_location), :draggable => true )
      @map.overlay_global_init(@marker,@marker_variable)
      @map.record_init @marker.on_dragend("gmap_update_position")

      respond_to do |format|
        format.html { render :action => "edit" }
      end
    end
  end

  # DELETE /wisps/:wisp_id/access_points/1
  def destroy

    @conf_fileName = "#{RAILS_ROOT}/private/access_points_configurations/ap-#{@access_point.wisp.id}-#{@access_point.id}.tar.gz"
    File.delete(@conf_fileName)

    @access_point.destroy

    respond_to do |format|
      format.html { redirect_to(wisp_access_points_url(@wisp)) }
    end
  end

  # Outdated access point update and summary
  # Actions redirects to a single ap when invoked on an ap show view (a single ap gets updated)
  def outdated_access_points_update
    @access_points = params[:id] ? [load_access_point] : @wisp.access_points.select {|ap| ap.is_outdated? }

    if params[:update]
      worker = MiddleMan.worker(:configuration_update_worker)
      worker.outdated_access_points_update(:arg => { :access_point_ids => @access_points.map{ |ap| ap.id } })
      @access_points = []
    end

    # Redirect if called on a single AP
    # Otherwise render the outdated_access_points_update view
    if params[:id]
      flash[:notice] = I18n.t(:AccessPoint_was_successfully_updated)
      redirect_to(wisp_access_point_url(@wisp, @access_point))
    end
  end

  # Ajax Methods
  def ajax_update_gmap
    @map = GMap.new(@div_variable, @map_variable)
    @map_variable = "map_new"
    @marker_variable = "marker_new"
    @div_variable = "div_new"

    location = (params['_address'].nil? ? '' : params['_address']) + ' ' + (params['_zip'].nil? ? '' : params['_zip']) + ' ' + (params['_city'].nil? ? '' : params['_city'])

    req_location = Geokit::Geocoders::GoogleGeocoder.geocode(location)
    if req_location.success
      @latlon = [req_location.lat, req_location.lng]
      @map = Variable.new(@map_variable)
      @marker = GMarker.new(@latlon, :title => t(:Select_location), :draggable => true)
      @map.overlay_global_init(@marker,@marker_variable)
      @map.record_init @marker.on_dragend("gmap_update_position")
      @zoom = (req_location.accuracy * 2.3).floor
    else
      @zoom = 12
    end

  end

end
