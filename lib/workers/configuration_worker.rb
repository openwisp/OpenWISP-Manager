# This file is part of the OpenWISP Manager
#
# Copyright (C) 2012 OpenWISP.org
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

class ConfigurationWorker < BackgrounDRb::MetaWorker
  set_worker_name :configuration_worker

  def create(args = nil)
    # this method is called, when worker is loaded for the first time
  end

  # Create access points configurations
  def create_access_points_configuration(options={})
    options[:access_point_ids] || raise("BUG: missing :access_point_ids arg")

    options[:access_point_ids].each do |ap_id|
      ap = AccessPoint.find(ap_id)

      unless ap.nil?
        begin
          File.delete(ACCESS_POINTS_CONFIGURATION_PATH + "ap-#{ap.wisp.id}-#{ap.id}.tar.gz")
        rescue
          puts "Info: " + $!.inspect
        end
        ap.generate_configuration
        ap.generate_configuration_md5
        ap.update_configuration!
      end
    end
    true
  end

  # Delete access points configurations
  def delete_access_points_configuration(options={})
    options[:access_point_ids] || raise("BUG: missing :access_point_ids arg")

    options[:access_point_ids].each do |ap_id|
      ap = AccessPoint.find(ap_id)
      unless ap.nil?
        begin
          File.delete(ACCESS_POINTS_CONFIGURATION_PATH + "ap-#{ap.wisp.id}-#{ap.id}.tar.gz")
        rescue
          puts "Warning: " + $!.inspect
        end
      end
    end

    true
  end

  # Create vpn server configurations
  def create_l2vpn_server_configuration(options={})
    options[:l2vpn_server_id] || raise("BUG: missing :vpn_server_id arg")

    l2vpn_server = L2vpnServer.find(options[:l2vpn_server_id])
    unless l2vpn_server.nil?
      begin
        File.delete(
            SERVERS_CONFIGURATION_PATH.join("server-openvpn-#{l2vpn_server.server.id}-#{l2vpn_server.id}.tar.gz")
        )
      rescue
          puts "Info: " + $!.inspect
      end

      # Dh and tls_auth generation could be a long process...
      l2vpn_server.dh = Ca.generate_dh
      l2vpn_server.tls_auth = Ca.generate_tls_auth_key
      l2vpn_server.save!

      l2vpn_server.generate_configuration
    end
    true
  end

  # Delete access points configurations
  def delete_l2vpn_server_configuration(options={})
    options[:l2vpn_server_id] || raise("BUG: missing :vpn_server_id arg")

    l2vpn_server = L2vpnServer.find(options[:l2vpn_server_id])
    unless l2vpn_server.nil?
      begin
        File.delete(
            SERVERS_CONFIGURATION_PATH.join("server-openvpn-#{l2vpn_server.server.id}-#{l2vpn_server.id}.tar.gz")
        )
      rescue
          puts "Warning: " + $!.inspect
      end
    end
    true
  end
    
  def update_redis_ap_info_by_group(options={})
     # Update AP Keys when updatinf a Group

    redis_s=Redis.new(:host => "test4.inroma.roma.it", :port => 6379, :db => 0)
    options[:access_point_group_id] || raise("BUG: missing :access_group_id arg")
    options[:method] || raise("BUG: missing :method")
    group=AccessPointGroup.find(options[:access_point_group_id][0])
    allap=AccessPoint.all(:conditions => [ "access_point_group_id = ?", options[:access_point_group_id][0] ])
    puts options[:access_point_group_id][0]
    allap.each do | ap |
       macaddress=ap.mac_address
       name=ap.name
       l2vpn_cert=ap.l2vpn_clients
       l2vpn_cert.each do |infocert|
          begin
            cert_id=infocert.id
            #puts infocert.id
            distinguished_name=X509Certificate.find(:first,:conditions => [ "certifiable_id = ?", cert_id]).dn
            commonname=distinguished_name.split("CN=")[1]
	    if options[:method] == "insert"
                url=group.site_url
	        redis_s.mapped_hmset("access_points:"+commonname, {"NAME" => name, "MACADDRESS"=> macaddress, "URL" => url})
	    elsif options[:method] == "delete"
	        redis_s.mapped_hmset("access_points:"+commonname, {"NAME" => name, "MACADDRESS"=> macaddress})
 	    end
          rescue Exception => e
             puts "Problem with Access Points "+ap.id.to_s+" "+group.site_url+" "+options[:method]+" "+commonname+" "+macaddress+" "+e.to_s
          end
       end
    end
  end

  def update_redis_ap_info(options={})
     # Update AP Keys when updating a Group

    redis_s=Redis.new(:host => "test4.inroma.roma.it", :port => 6379, :db => 0)
    options[:access_point_id] || raise("BUG: missing :access_point_id arg")
    options[:method] || raise("BUG: missing :method")
    options[:access_point_id].each do |ap_x| 
       ap=AccessPoint.find(ap_x)
       macaddress=ap.mac_address
       name=ap.name
       l2vpn_cert=ap.l2vpn_clients
       l2vpn_cert.each do |infocert|
         begin
           cert_id=infocert.id
           #puts infocert.id
           distinguished_name=X509Certificate.find(:first,:conditions => [ "certifiable_id = ?", cert_id]).dn
           commonname=distinguished_name.split("CN=")[1]
           if options[:method]=="insert"
             redis_s.mapped_hmset("access_points:"+commonname, {"NAME" => name, "MACADDRESS"=> macaddress})
           elsif options[:method]=="delete"
             redis_s.del("access_points:"+commonname)
           end
         rescue Exception => e
           puts "Problem with Access Points "+ap.id.to_s+" "+e.to_s
         end
       end
    end
  end
end
