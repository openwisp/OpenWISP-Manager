require 'openssl'

class X509Certificate < ActiveRecord::Base
  acts_as_authorization_object :subject_class_name => 'Operator'

  validates_presence_of :dn, :certificate, :key

  belongs_to :ca
  belongs_to :certifiable, :polymorphic => true

  somehow_has :one => :access_point, :through => :certifiable, :if => Proc.new {|instance| instance.is_a? AccessPoint }
  somehow_has :many => :access_points, :through => :certifiable, :if => Proc.new {|instance| instance.is_a? AccessPoint }

  before_save :outdate_configuration_if_required
  after_destroy :outdate_configuration_if_required

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

  private

  def outdate_configuration_if_required
    # If we modify this instance, we must mark the related AP configuration as outdated.
    # This is only applicable for ethernet 'attached' to access points
    #TODO: Find a solution and fix the Array bug!
    if !new_record? && (changed? || destroyed?)
      related_access_point.outdate_configuration! if related_access_point
      related_access_points.each{|ap| ap.outdate_configuration!}
    end
  end
end
