class ServerBridgesController < ApplicationController
  layout nil

  before_filter :load_server
  before_filter :load_bridge, :except => [ :index, :new, :create ]

  access_control :subject_method => :current_operator do
    default :deny

    allow :admin
  end

  def load_server
    @server = Server.find(params[:server_id])
  end
  
  def load_bridge
    @bridge = @server.bridges.find(params[:id]) 
  end

  def index
    @bridges = @server.bridges.find(:all)
    
    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def new
    @bridge  = @server.bridges.build()

    # Present to the view only unbridged interface
    @taps = @server.taps.select { |t| 
      t.bridge.nil?
    }
    @ethernets = @server.ethernets.select { |v| 
      v.bridge.nil?
    }
    @vlans = @server.vlans.select { |v| 
      v.bridge.nil?
    }

    @selected_taps = []
    @selected_ethernets = []
    @selected_vlans = []

    @addressing_mode = "none"

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  def edit
    # Present to the view only unbridged interface or interface linked to this bridge
    @taps = @server.taps.select { |t| 
      t.bridge.nil? or t.bridge == @bridge
    }
    @ethernets = @server.ethernets.select { |e| 
      e.bridge.nil? or e.bridge == @bridge
    }
    @vlans = @server.vlans.select { |v| 
      v.bridge.nil? or v.bridge == @bridge
    }    
    
    @selected_taps = @bridge.taps.map { |t| t.id }
    @selected_ethernets = @bridge.ethernets.map { |e| e.id }
    @selected_vlans = @bridge.vlans.map { |v| v.id }

    @addressing_mode = @bridge.addressing_mode
  end

  # POST /wisps/:wisp_id/access_points/:access_point_id/bridges
  def create
    @bridge = @server.bridges.build(params[:bridge])

    # Present to the view only unbridged interface
    @taps = @server.taps.select { |t| 
      t.bridge.nil?
    }
    @ethernets = @server.ethernets.select { |e| 
      e.bridge.nil?
    }
    @vlans = @server.vlans.select { |v| 
      v.bridge.nil?
    }
    
    @selected_taps = params[:taps].nil? ? [] : params[:taps].collect { |s| s.to_i }
    @bridge.taps = @selected_taps.map { |t|
      @server.taps.find(t) 
    }

    @selected_ethernets = params[:ethernets].nil? ? [] : params[:ethernets].collect { |s| s.to_i }
    @bridge.ethernets = @selected_ethernets.map { |e| 
      @server.ethernets.find(e) 
    }
    
    @selected_vlans = params[:vlans].nil? ? [] : params[:vlans].collect { |s| s.to_i }
    @bridge.vlans = @server.vlans.select { |v|  
      @selected_vlans.include?(v.id) 
    }

    @addressing_mode = params[:bridge][:addressing_mode]

    respond_to do |format|
      if @bridge.save
        #flash[:notice] = 'Bridge was successfully created.'
        format.html { 
          redirect_to(server_bridges_url(@server))
        }
      else
        format.html { render :action => "new" }
      end
    end
  end

  def update
    @bridge = @server.bridges.find(params[:id])

    @addressing_mode = params[:bridge][:addressing_mode]

    # Present to the view only unbridged interface or interface linked to this bridge
    @taps = @server.taps.select { |t| 
      t.bridge.nil? or t.bridge == @bridge
    }
    @ethernets = @server.ethernets.select { |e| 
      e.bridge.nil? or e.bridge == @bridge
    }
    @vlans = @server.vlans.select { |v| 
      v.bridge.nil? or v.bridge == @bridge
    }

    @selected_taps = params[:taps].nil? ? [] : params[:taps].collect { |s| s.to_i }
    @selected_ethernets = params[:ethernets].nil? ? [] : params[:ethernets].collect { |s| s.to_i }
    @selected_vlans = params[:vlans].nil? ? [] : params[:vlans].collect { |s| s.to_i }


    # Unbridge or bridge taps
    taps = @selected_taps.map { |t| 
      @server.taps.find(t) 
    }
    (taps - @bridge.taps).each { |t|
      t.do_bridge!(@bridge)
    }
    (@bridge.taps - taps).each { |t|
      t.do_unbridge!
    }
    @bridge.taps = taps

    # Unbridge or bridge ethernets
    ethernets = @selected_ethernets.map { |e| 
      @server.ethernets.find(e)
    }
    (ethernets - @bridge.ethernets).each { |e|
      e.do_bridge!(@bridge)
    }
    (@bridge.ethernets - ethernets).each { |e|
      e.do_unbridge!
    }
    @bridge.ethernets = ethernets

    # Unbridge or bridge vlans
    vlans = @selected_vlans.map { |v|
      # HACK: should be "find"... but we have a (non-activerecord) array :(
      @server.vlans.detect { |i| i.id == v }
    }
    (vlans - @bridge.vlans).each { |v|
      v.do_bridge!(@bridge)
    }
    (@bridge.vlans - vlans).each { |v| 
      v.do_unbridge!
    }
    @bridge.vlans = vlans

    respond_to do |format|
      if @bridge.update_attributes(params[:bridge])
        #flash[:notice] = 'Bridge was successfully updated.'
        format.html { 
          redirect_to(server_bridges_url(@server))
        }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  # DELETE /wisps/:wisp_id/access_points/:access_point_id/bridges/1
  def destroy
    @bridge  = @server.bridges.find(params[:id])
    # dependents => :nullify in bridge model will remove any reference to this bridge
    @bridge.destroy

    respond_to do |format|
      format.html { 
        redirect_to(server_bridges_url(@server))
      }
    end
  end
end
