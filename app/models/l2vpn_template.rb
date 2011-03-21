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

  after_save :outdate_configuration_if_required
  after_destroy :outdate_configuration_if_required

  # Update l2vpn instances
  after_create do |record|
    if record.l2vpn_clients.length == 0
      record.access_point_template.access_points.each do |h|
        nv = h.l2vpn_clients.build(:access_point => h)
        nv.link_to_template(record)
        nv.save
      end
    end
  end

  private

  OUTDATING_ATTRIBUTES = [:l2vpn_server_id, :id]

  def outdate_configuration_if_required
    if destroyed? or OUTDATING_ATTRIBUTES.any? { |attribute| send "#{attribute}_changed?" }
      if related_access_points
        related_access_points.each { |access_point| access_point.outdate_configuration! }
      end
    end
  end

end
