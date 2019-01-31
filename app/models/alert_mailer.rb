class AlertMailer < ActionMailer::Base

   def send_email(wisp_id='1')
    recipients   "recipient@email.it"
    subject      "New account information"
    from         "from@email.it"
    content_type "text/plain"

    wisp = Wisp.find_by_id(wisp_id)
    #Secondi in due mesi
    second_expiring = 5184000.seconds
    list_vpn_to_renew=""
    list_ca_to_renew=""
    ap_count=0
    ca = wisp.ca
    ca.x509_certificates.each do |cert|
      if cert.certifiable_type == "L2vpnClient" and (OpenSSL::X509::Certificate.new(ca.x509_certificate.certificate).not_after - Time.now.utc < second_expiring)
        ca.renew_certificate!(cert)
        ap_count +=1
        puts "Certificato rinnovato in automatico "+OpenSSL::X509::Certificate.new(ca.x509_certificate.certificate).not_after.to_s
      end
      if cert.certifiable_type == "L2vpnServer" and (OpenSSL::X509::Certificate.new(ca.x509_certificate.certificate).not_after - Time.now.utc < second_expiring)
        list_vpn_to_renew +="\t"+cert.dn[cert.dn.index("CN=")+3, cert.dn.length]+","+OpenSSL::X509::Certificate.new(ca.x509_certificate.certificate).not_after.to_s
        puts "Il certificato SERVER sta per scadere "+OpenSSL::X509::Certificate.new(ca.x509_certificate.certificate).not_after.to_s
      end
      if cert.certifiable_type == "Ca" and (OpenSSL::X509::Certificate.new(ca.x509_certificate.certificate).not_after - Time.now.utc < second_expiring)
        list_ca_to_renew +="\t"+cert.dn[cert.dn.index("CN=")+3, cert.dn.length]+","+OpenSSL::X509::Certificate.new(ca.x509_certificate.certificate).not_after.to_s
        puts "Il certificato della CERTIFICATION AUTHORITY sta per scadere "+OpenSSL::X509::Certificate.new(ca.x509_certificate.certificate).not_after.to_s
      end
    end
    apall=wisp.access_points
    apall.each do |ap|
      unless ap.nil?
       begin
        if ap.configuration_outdated
         File.delete(ACCESS_POINTS_CONFIGURATION_PATH + "ap-#{ap.wisp.id}-#{ap.id}.tar.gz")
         ap.generate_configuration
         ap.generate_configuration_md5
         ap.update_configuration!
        end
       rescue Exception => e
        puts e.message
        puts "Non riesco a rinnovare il certificato dell'access point "+ap.name;
       end
      end
    end
    puts list_vpn_to_renew
    corpo={:list_vpn_to_renew => list_vpn_to_renew, :list_ca_to_renew => list_ca_to_renew, :ap_count => ap_count}
    body     corpo
   end
end
