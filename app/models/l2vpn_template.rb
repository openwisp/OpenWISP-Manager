class L2vpnTemplate < ActiveRecord::Base
  acts_as_authorization_object :subject_class_name => 'Operator'

  validates_uniqueness_of :l2vpn_server_id, :scope => :access_point_template_id
  validates_presence_of :l2vpn_server_id

  has_one :tap_template, :dependent => :destroy
  belongs_to :access_point_template
  belongs_to :l2vpn_server

  # Template instances
  has_many :l2vpn_clients, :dependent => :destroy

  somehow_has :many => :access_points, :through => :access_point_template

  before_save do |record|
    record.related_access_points.each{|ap| ap.configuration_outdated!} if record.new_record? || record.changed?
  end

  after_destroy do |record|
    record.related_access_points.each{|ap| ap.configuration_outdated!}
  end

  # Update l2vpn instances
  after_create do |record|
    if record.l2vpn_clients.length == 0
      record.access_point_template.access_points.each do |h|
        nv = h.l2vpn_clients.build( :access_point => h )
        nv.link_to_template( record )
        nv.save
      end
    end
  end

end
