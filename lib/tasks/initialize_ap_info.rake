namespace :redis do
  desc "Initialize redis database with captive page and access points info."
  task :load_all_ap_info => :environment do
    redis_s=Redis.new(:host => "test4.inroma.roma.it", :port => 6379, :db => 0)
    wisp = Wisp.find_by_id(ENV['wisp'])
    wisp.access_points.each do |ap| 
       MACADDRESS=ap.mac_address
       NAME=ap.name
       group=ap.access_point_group_id
       gr=AccessPointGroup.find_by_id(group) 
       begin
          URL=gr.site_url
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
          distinguished_name=X509Certificate.find(cert_id).dn
          COMMONNAME=distinguished_name.split("CN=")[1]	  
          puts NAME+" "+MACADDRESS+" "+URL+" "+COMMONNAME
          rescue Exception => e
		puts "Problem with Access Points "+ap.id.to_s
	  end
       end
       redis_s.mapped_hmset("access_points:l2vpn_client_2_1805_1797", {"NAME" => "unifi_test", "MACADDRESS"=> "dc:9f:db:26:7b:69"})
    end
  end
  task :help do
    puts "Usage: rake redis:load_all_ap_info wisp=<wisp_id>"
  end
end
