class AccessPointsController < ApplicationController
  include Addons::Mappable

  before_filter :load_wisp, :except => [:get_configuration, :get_configuration_md5]
  before_filter :load_access_point,
                :except => [
                    :index,
                    :new, :create,
                    :ajax_update_gmap,
                    :get_configuration, :get_configuration_md5,
                    :outdated, :update_outdated
                ]

  access_control do
    default :deny

    actions :index, :show, :outdated do
      allow :wisps_viewer
      allow :access_points_viewer, :of => :wisp
    end

    actions :new, :create, :ajax_update_gmap do
      allow :wisps_creator
      allow :access_points_creator, :of => :wisp
    end

    actions :edit, :update, :update_outdated, :ajax_update_gmap do
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
        if access_point.last_configuration_retrieve_ip != request.remote_ip
          access_point.update_attributes(:last_configuration_retrieve_ip => request.remote_ip)
        end
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
    @map.control_init(:small_map => true, :map_type => true)
    @map.set_map_type_init(GMapType::G_NORMAL_MAP)
    @map.center_zoom_init(@latlon, @zoom)
    @marker = GMarker.new(@latlon, :title => @access_point.name)
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
    llz = get_center_zoom(@wisp.access_points)
    @latlon = llz[0,2]
    @zoom = llz[2]

    @map = GMap.new(@div_variable, @map_variable)
    @map.control_init(:small_map => true,:map_type => true)
    @map.set_map_type_init(GMapType::G_NORMAL_MAP)
    @map.center_zoom_init(@latlon, @zoom)
    @marker = GMarker.new(@latlon, :title => t(:Select_location), :draggable => true, :icon => draggable_marker_icon )
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
    @map.control_init(:small_map => true,:map_type => true)
    @map.set_map_type_init(GMapType::G_NORMAL_MAP)
    @map.center_zoom_init(@latlon, @zoom)
    @marker = GMarker.new(@latlon, :title => t(:Select_location), :draggable => true, :icon => draggable_marker_icon )

    @near_aps = AccessPoint.find(:all, :origin => @latlon, :within => 1)
    @near_aps.delete @access_point
    @near_aps.each do |ap| 
      info = render_to_string(:partial => "info_window", :layout => false, :locals => { :access_point => ap })
      @map.overlay_init(GMarker.new([ap.lat, ap.lon], :title => ap.name, :info_window => info))
    end

    @map.overlay_global_init(@marker, @marker_variable)
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
    @access_points = @wisp.access_points.select {|ap| ap.is_outdated? }
  end

  def update_outdated
    # TODO: some ajax-magic is needed here...
    access_points = params[:id] ? [load_access_point] : @wisp.access_points.select {|ap| ap.is_outdated? }

    worker = MiddleMan.worker(:configuration_worker)
    worker.async_create_access_points_configuration(:arg => { :access_point_ids => access_points.map{ |ap| ap.id } })

    redirect_to wisp_access_points_url(@wisp)
  end

  # Ajax Methods
  def ajax_update_gmap
    @map = GMap.new(@div_variable, @map_variable)
    @map_variable = "map_new"
    @marker_variable = "marker_new"
    @div_variable = "div_new"

    city    = params[:access_point][:city]     or ''
    address = params[:access_point][:address]  or ''
    zip     = params[:access_point][:zip]      or ''

    location = [address, zip, city].join(' ')

    req_location = Geokit::Geocoders::GoogleGeocoder.geocode(location)
    if req_location.success
      latlon_arr = [req_location.lat, req_location.lng]
      @latlon = GLatLng.new(latlon_arr)

      @near_aps = AccessPoint.find(:all, :origin => latlon_arr, :within => 1)
      @near_aps.map! do |ap| 
        info = render_to_string(:partial => "info_window", :layout => false, :locals => { :access_point => ap })
	GMarker.new([ap.lat, ap.lon], :title => ap.name, :info_window => info)
      end

      @map = Variable.new(@map_variable)
      @marker = GMarker.new(latlon_arr, :title => t(:Select_location), :draggable => true, :icon => draggable_marker_icon)
      @map.overlay_init([@marker, @near_aps].flatten,@marker_variable)
      @map.record_init @marker.on_dragend("gmap_update_position")
      @zoom = (req_location.accuracy * 2.3).floor
    end
  end

  private

  def load_access_point
    @access_point = @wisp.access_points.find(params[:id])
  end

  def draggable_marker_icon
    GIcon.new(
	:image => 'http://maps.gstatic.com/intl/en_en/mapfiles/ms/micons/grn-pushpin.png', 
	:icon_size => GSize.new(32,32), 
	:icon_anchor => GPoint.new(12,38),
	:shadow => 'http://maps.gstatic.com/intl/en_en/mapfiles/ms/micons/pushpin_shadow.png'
    )
  end
end
