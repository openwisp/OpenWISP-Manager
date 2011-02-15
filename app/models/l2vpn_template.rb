class L2vpnTemplate < ActiveRecord::Base
  acts_as_authorization_object :subject_class_name => 'Operator'

  acts_as_markable_on_change :watch_for => :l2vpn_server, :notify_on_destroy => :access_point_template

  validates_uniqueness_of :l2vpn_server_id, :scope => :access_point_template_id
  validates_presence_of :l2vpn_server_id

  has_one :tap_template, :dependent => :destroy
  belongs_to :access_point_template, :touch => true
  belongs_to :l2vpn_server

  # Template instances
  has_many :l2vpn_clients, :dependent => :destroy

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
