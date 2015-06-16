ActionController::Routing::Routes.draw do |map|
  # NAMED ROUTES
  # Get certificate revocation list
  map.wisp_ca_crl 'wisps/:wisp_id/ca/crl', :controller => 'cas', :action => 'crl'
  # All outdated access points summary
  map.outdated_access_points 'wisps/:wisp_id/access_points/outdated', :controller => 'access_points', :action => 'outdated'
  # Outdated access point update (either single or all)
  map.outdated_access_points_update 'wisps/:wisp_id/access_points/update_outdated/:id', :controller => 'access_points', :action => 'update_outdated'
  map.welcome_operator 'operators/:id', :controller => 'operators', :action => 'show'
  # access point attachments
  map.access_point_attachment 'wisps/:wisp_id/access_points/:id/attachments/:file_num', :controller => 'access_points', :action => 'attachment', :conditions => { :method => :get }, :requirements => { :file_num => /\d/ }

  #Ajax Routes
  map.connect 'wisps/:wisp_id/access_points_ajax', :controller => 'access_points', :action => 'index', :ajax => 'true'
  map.connect 'wisps/:wisp_id/access_point_templates/ajax_stats', :controller => 'access_point_templates', :action => 'ajax_stats'
  map.connect 'wisps/ajax_stats', :controller => 'wisps', :action => 'ajax_stats'
  map.connect 'servers/ajax_stats', :controller => 'servers', :action => 'ajax_stats'
  map.connect 'radio_templates/modes_for_driver', :controller => 'radio_templates', :action => 'modes_for_driver'
  map.connect 'radio_templates/channels_for_mode', :controller => 'radio_templates', :action => 'channels_for_mode'
  map.connect 'radios/modes_for_driver', :controller => 'radios', :action => 'modes_for_driver'
  map.connect 'radios/channels_for_mode', :controller => 'radios', :action => 'channels_for_mode'

  map.get_config 'get_config/:mac_address', :controller => 'access_points', :action => 'get_configuration'
  map.get_config_md5 'get_config/:mac_address.md5', :controller => 'access_points', :action => 'get_configuration_md5'
  map.get_server_config 'get_server_config/:id', :controller => 'l2vpn_servers', :action => 'get_server_configuration'

  map.resources :custom_scripts
  map.resources :custom_script_templates

  map.resource :login, :controller => "operator_sessions", :action => "new"
  map.resource :logout, :controller => "operator_sessions", :method => "delete"
  map.resource :operator_session
  map.root :controller => "operator_sessions", :action => "new"

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

      map.revoke_certificate 'wisps/:wisp_id/ca/x509_certificates/:id/revoke',
                             :controller => 'x509_certificates',
                             :action => 'revoke'

      map.renew_certificate 'wisps/:wisp_id/ca/x509_certificates/:id/renew',
                            :controller => 'x509_certificates',
                            :action => 'renew'

      map.reissue_certificate 'wisps/:wisp_id/ca/x509_certificates/:id/reissue',
                              :controller => 'x509_certificates',
                              :action => 'reissue'
    end

    wisp.resources :access_point_groups
    wisp.resources :template_groups
    wisp.resources :l2vpn_clients, :only => :show

    wisp.resources :access_points do |access_point|
      access_point.resources :ethernets
      access_point.resources :vlans
      access_point.resources :radios
      access_point.resources :bridges
      access_point.resources :l2vpn_clients
      access_point.resources :l2tcs
      access_point.resources :custom_scripts
      access_point.resources :access_point_groups, :only => :index
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
