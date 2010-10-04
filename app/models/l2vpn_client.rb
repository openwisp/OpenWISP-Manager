class L2vpnClient < ActiveRecord::Base
  acts_as_authorization_object :subject_class_name => 'Operator'

  has_one :tap, :as => :l2vpn, :dependent => :destroy  
  has_one :x509_certificate, :as => :certificable, :dependent => :destroy
  belongs_to :access_point, :touch => true

  belongs_to :l2vpn_template
  belongs_to :template, :class_name => 'L2vpnTemplate', :foreign_key => :l2vpn_template_id
  
  belongs_to :l2vpn_server

  after_create { |record|
    record.access_point.wisp.ca.create_openvpn_client_certificate(record)
  }

  def link_to_template(template)
    self.l2vpn_template = template

    unless self.l2vpn_template.tap_template.nil?
      self.tap = Tap.new( :l2vpn => self )
      self.tap.link_to_template( self.l2vpn_template.tap_template )
      self.tap.save
    end
  end

  # Certificable interface
  def identifier
    "l2vpn_client_#{self.access_point.wisp.id}_#{self.access_point.id}_#{self.id}"
  end

  # Accessor methods (read)
  def machine
    self.access_point
  end
  
  def l2vpn_server
    if (read_attribute(:l2vpn_server_id).blank? or read_attribute(:l2vpn_server_id).nil?) and !template.nil?
      return template.l2vpn_server
    end

    return L2vpnServer.find(read_attribute(:l2vpn_server_id))
  end
  
  def name
    l2vpn_server.name
  end
  
end
