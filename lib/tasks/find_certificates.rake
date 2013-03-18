namespace :certs do 
  desc "renew all certificates for a specified wisp"
  task :renew_all => :environment do 
    wisp = Wisp.find_by_id(ENV['wisp'])
    ca = wisp.ca
    ca.x509_certificates.each do |cert|
      if cert.certifiable_type == "L2vpnClient"
        ca.renew_certificate!(cert)
      end
    end
  end
  task :help do
    puts "Usage: rake certs:renew_all wisp=<wisp_id>"
  end
end
