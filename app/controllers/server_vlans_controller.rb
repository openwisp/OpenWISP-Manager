class ServerVlansController < ApplicationController
  layout nil

  before_filter :load_server
  before_filter :load_vlan, :except => [ :index, :new, :create ]
  
  access_control :subject_method => :current_operator do
    default :deny

    allow :admin
  end

  def load_server
    @server = Server.find(params[:server_id])
  end
  
  def load_vlan
    @vlan = @server.vlans
  end
  
  def index

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def new
    @devices = @server.interfaces
    @taps = @server.taps
    @ethernets = @server.ethernets

    @interface_select = @taps.map { |t| [ t.friendly_name, "#{t.id}_tap" ] }
    @interface_select.concat(@ethernets.map { |e| [ e.friendly_name, "#{e.id}_ethernet" ] })
    @interface_select_selected = []
 
    @vlan = Vlan.new()

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  def create
    @taps = @server.taps
    @ethernets = @server.ethernets

    @interface_select = @taps.map { |t| [ t.friendly_name, "#{t.id}_tap" ] }
    @interface_select.concat(@ethernets.map { |e| [ e.friendly_name, "#{e.id}_ethernet" ] })

    unless params[:interface_select].nil?
      @idt = params[:interface_select].split('_')
      if @idt[1] == 'tap'
        interface = @taps.find(@idt[0])
      elsif @idt[1] == 'ethernet'
        interface = @ethernets.find(@idt[0])
      end
      @vlan = interface.vlans.build(params[:vlan])
    end

    respond_to do |format|
      if @vlan.save
        format.html { 
          redirect_to(server_vlans_url(@server)) 
        }
      else
        format.html { render :action => "new" }
      end
    end
    
  end

  def destroy
    @vlan = Vlan.find(params[:id])
    @vlan.destroy
    
    respond_to do |format|
      format.html { redirect_to(server_vlans_url(@server)) }
    end
  end
end
