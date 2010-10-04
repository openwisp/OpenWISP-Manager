ActionController::Routing::Routes.draw do |map|
  map.resources :custom_scripts

  map.resources :custom_script_templates


  map.resource :login, :controller => "operator_sessions", :action => "new"
  map.resource :logout, :controller => "operator_sessions", :method => "delete"
  map.resource :operator_session
  map.root :controller => "operator_sessions", :action => "new"
  
  #Ajax Routes
  map.connect 'access_point/ajax_update_gmap', :controller => 'access_points', :action => 'ajax_update_maps'
  map.connect 'access_point_templates/ajax_stats', :controller => 'access_point_templates', :action => 'ajax_stats'
  map.connect 'wisps/ajax_stats', :controller => 'wisps', :action => 'ajax_stats'
  map.connect 'servers/ajax_stats', :controller => 'servers', :action => 'ajax_stats'
  
  map.connect 'get_config/:mac_address', :controller => 'access_points', :action => 'get_configuration'
  map.connect 'get_config/:mac_address.md5', :controller => 'access_points', :action => 'get_configuration_md5'
  
  map.connect 'wisps/:id/get_crl_list', :controller => 'wisps', :action => 'get_crl_list'
  

  map.resources :servers do |server|
    server.resources :l2vpn_servers
    server.resources :ethernets, :controller => :server_ethernets
    server.resources :vlans, :controller => :server_vlans
    server.resources :bridges, :controller => :server_bridges
  end

  map.resources :wisps do |wisp|

    wisp.resources :operators
  
    wisp.resource :ca do |ca|
      ca.resources :x509_certificates
    end
  
    wisp.resources :access_point_groups
    wisp.resources :template_groups

    wisp.resources :access_points do |access_point|
      access_point.resources :ethernets
      access_point.resources :vlans
      access_point.resources :radios
      access_point.resources :bridges
      access_point.resources :l2vpn_clients
      access_point.resources :l2tcs
      access_point.resources :custom_scripts
      
      access_point.resource :weekly_monitoring_access_point
			access_point.resource :hourly_monitoring_access_point
    end

    wisp.resources :access_point_templates do |access_point_template|
      access_point_template.resources :ethernet_templates
      access_point_template.resources :vlan_templates
      access_point_template.resources :radio_templates
      access_point_template.resources :bridge_templates
      access_point_template.resources :l2vpn_templates
      access_point_template.resources :l2tc_templates
      access_point_template.resources :custom_script_templates
    end

  end

  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
