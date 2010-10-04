class WispsController < ApplicationController
  include MappablesAddons

  before_filter :load_wisp, :except => [:index, :new, :create]
  
  access_control :subject_method => :current_operator do
    default :deny

    allow :admin
    allow :wisp_admin, :of => :wisp, :to => [:show, :edit, :update, :ajax_stats]
    allow :wisp_operator, :of => :wisp, :to => [:show, :ajax_stats]
    allow :wisp_viewer, :of => :wisp, :to => [:show, :ajax_stats]
  end

  def load_wisp
    @wisp = Wisp.find(params[:id])
  end


  # GET /wisps
  def index
    @wisps = Wisp.find(:all)

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /wisps/1
  def show
    @access_points = @wisp.access_points.find(:all)
    
    @map_variable = "map_new"
    @marker_suffix_variable = "marker_suffix_"
    @div_variable = "div_new"
          
    if @access_points.length > 0
      llz = get_center(@wisp.access_points)
      @latlon = llz[0,2]
    else
      @wisp_address_locality =  Ca.find_by_wisp_id(@wisp.id).l + " " + Ca.find_by_wisp_id(@wisp.id).st
      @latlon = get_wisp_geocode(@wisp_address_locality)

      @zoom = 10
    end
    
    @map = GMap.new(@div_variable, @map_variable)
    @map.control_init(:large_map => true, :map_type => true)
    @map.set_map_type_init(GMapType::G_HYBRID_MAP)
    @map.center_zoom_init(@latlon, @zoom)

    if @access_points.length > 0
      
      sorted_latitudes = @access_points.collect(&:lat).compact.sort
      sorted_longitudes = @access_points.collect(&:lon).compact.sort

      @map.center_zoom_on_bounds_init([
          [sorted_latitudes.first, sorted_longitudes.first], 
          [sorted_latitudes.last, sorted_longitudes.last]])

      @access_points.each do |ap|
        info = <<ENI
<table>
<tr>
  <td><b>#{t(:Name)}</b></td>
  <td>#{ap.name}</td>
</tr>
  <td><b>#{t(:Address)}</b></td>
  <td>#{ap.address}</td>
</tr>
  <td><b>#{t(:City)}</b></td>
  <td>#{ap.city}</td>
</tr>
</table>
ENI
        marker = GMarker.new([ap.lat, ap.lon], :title => ap.name, :draggable => false, :info_window => info)
        @map.overlay_global_init(marker, @marker_suffix_variable + "#{ap.name.gsub(/\-/,'_')}")
      end
    else
      info = <<ENI
<table>
<tr>
<td><b>#{@wisp.name}</b> - #{@wisp_address_locality} </td>
</tr>
<tr>
<td></td>
</tr>
<td><i><b>#{t(:Wisp_still_without_aps)}</b></i></td>
</tr>
</tr>
<td><i>#{t(:Wisp_for_creation_of_ap_use_panel)}</i></td>
</tr>
</table>
ENI
      marker = GMarker.new(@latlon, :title => @wisp.name, :draggable => false, :info_window => info)
      @map.overlay_global_init(marker, "wispAddressInfo")
    end  
    
    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # GET /wisps/new
  def new
     @wisp = Wisp.new
     @wisp.ca = Ca.new

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /wisps/1/edit
  def edit

    respond_to do |format|
      format.html # edit.html.erb
    end
  end
  
  # POST /wisps
  def create
    @wisp = Wisp.new(params[:wisp])
    @wisp.ca.cn = @wisp.name

    respond_to do |format|
      if @wisp.save
        flash[:notice] = t(:Wisp_was_successfully_created)
        format.html { redirect_to(wisps_url) }
      else
        format.html { render :action => "new" }
      end
    end
  end

  # POST /wisps/1
  def update

    respond_to do |format|
      if @wisp.update_attributes(params[:wisp])
        flash[:notice] = t(:Wisp_was_successfully_updated)
        format.html { redirect_to(wisp_url(@wisp)) }
      else
        format.html { render :action => "edit" }
      end
    end
  end
  
  def get_crl_list
     send_data @wisp.ca.crl_list
  end
  
  # DELETE /wisps/1
  def destroy
    @wisp.destroy

    respond_to do |format|
      format.html { redirect_to(wisps_url) }
    end
  end
  
  # Ajax Methods
  def ajax_stats
    
    respond_to do |format|
      format.html { render :partial => "stats", :object => @wisp }
    end
  end
  
end
