require 'openssl'

class X509Certificate < ActiveRecord::Base
  acts_as_authorization_object :subject_class_name => 'Operator'

  validates_presence_of :dn, :certificate, :key

  belongs_to :ca
  belongs_to :certificable, :polymorphic => true

  def revoked?
    revoked == true
  end

  def expired?
    c = OpenSSL::X509::Certificate.new(self.certificate)
    c.not_after < Time.now
  end

  def to_text
    c = OpenSSL::X509::Certificate.new(self.certificate)
    c.to_text
  end
  
  def revoke
    unless self.revoked
      self.revoked = true
      
      now = Time.at(Time.now.to_i)
      c = OpenSSL::X509::Certificate.new(self.certificate)
      ca = X509Certificate.find(:first, :conditions => {:ca_id => self.ca_id, :certificable_type => "Ca"})
      ca_cert = OpenSSL::X509::Certificate.new(ca.certificate)
      
      if self.ca.crl_list.nil?
        crl_list = OpenSSL::X509::CRL.new()
      else
        crl_list = OpenSSL::X509::CRL.new(self.ca.crl_list)
      end
      
      crl_list.issuer = ca_cert.issuer
      crl_list.version = 3
      crl_list.last_update = now
      crl_list.next_update = now+1600
      
      revoked = OpenSSL::X509::Revoked.new
      revoked.serial = c.serial
      revoked.time = now
      
      reason_code = 1 # Actually Key Compromise
      enum = OpenSSL::ASN1::Enumerated(reason_code)
      ext = OpenSSL::X509::Extension.new("CRLReason", enum)      
      
      revoked.add_extension(ext)
      crl_list.add_revoked(revoked)
      
      # If needed signed! 
      crl_list.sign(OpenSSL::PKey::RSA.new(ca.key), OpenSSL::Digest::SHA1.new)
      
      self.ca.crl_list = crl_list.to_pem
      self.ca.save
      self.save
    end
  end
  
  def destroy
    revoke
  end
end
