namespace :redis do
  desc "Initialize redis database with captive page and access points info."
  task :load_all_ap_info => :environment do
    redis_s=Redis.new(:host => "test4.inroma.roma.it", :port => 6379, :db => 0)
    wisp = Wisp.find_by_id(ENV['wisp'])
    wisp.access_points.each do |ap| 
       macaddress=ap.mac_address
       name=ap.name
       group=ap.access_point_group_id
       gr=AccessPointGroup.find_by_id(group) 
       begin
          url=gr.site_url
       rescue Exception => e
       end
       l2vpn_cert=ap.l2vpn_clients
      
       #puts macaddress
       l2vpn_cert.each do |infocert|
       #145 = l2vpn_cert.id
       #151 = ap_id
       #dn=x509_certificates.l2vpn_cert.id
       #"/C=Italia/ST=RM/L=Roma/O=Provincia di Roma/CN=l2vpn_client_1_151_145"
          begin
          cert_id=infocert.id
          #puts infocert.id
	  distinguished_name=X509Certificate.find(:first,:conditions => [ "certifiable_id = ?", cert_id]).dn
          commonname=distinguished_name.split("CN=")[1]	  
          redis_s.mapped_hmset("access_points:"+commonname, {"NAME" => name, "MACADDRESS"=> macaddress, "URL" => url})
          rescue Exception => e
		puts "Problem with Access Points "+ap.id.to_s
                puts name+" "+macaddress+" "+url+" "+commonname
	  end
       end
    end
  end
  task :help do
    puts "Usage: rake redis:load_all_ap_info wisp=<wisp_id>"
  end
end
