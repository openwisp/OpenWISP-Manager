require 'openssl'

class X509Certificate < ActiveRecord::Base
  acts_as_authorization_object :subject_class_name => 'Operator'

  validates_presence_of :dn, :certificate, :key

  belongs_to :ca
  belongs_to :certifiable, :polymorphic => true

  somehow_has :many => :access_points, :through => :certifiable, :if => Proc.new { self.certifiable.class != L2vpnClient }

  before_save do |record|
    # If we modify this instance, we must mark the related APs configuration as outdated.
    if record.certifiable.class == L2vpnClient
      # If this certificate belongs to a l2 vpn client, we have to mark a single AP
      record.certifiable.access_point.configuration_outdated! if !record.new_record?
    else
      record.related_access_points.each{|ap| ap.configuration_outdated!}
    end
  end

  after_destroy do |record|
    # If we modify this instance, we must mark the related APs configuration as outdated.
    record.related_access_points.each{|ap| ap.configuration_outdated!}
  end

  def x509_valid?
    !revoked? and !expired?
  end

  def revoked?
    self.revoked == true
  end

  def expired?
    c = OpenSSL::X509::Certificate.new(self.certificate)
    c.not_after < Time.now
  end

  def revoke!
    self.ca.revoke!(self.id)
  end

  def expiry_date
    OpenSSL::X509::Certificate.new(self.certificate).not_after
  end

  def to_text
    c = OpenSSL::X509::Certificate.new(self.certificate)
    c.to_text
  end

end
