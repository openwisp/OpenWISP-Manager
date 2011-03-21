class EthernetTemplate < ActiveRecord::Base
  acts_as_authorization_object :subject_class_name => 'Operator'

  NAME_PREFIX = "eth"

  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :access_point_template_id
  validates_format_of :name, :with => /\A[a-z][\s\w\d_\.]*\Z/i
  validates_length_of :name, :maximum => 8

  belongs_to :bridge_template

  belongs_to :access_point_template

  has_one :l2tc_template, :as => :shapeable_template, :dependent => :destroy

  has_many :vlan_templates, :as => :interface_template, :dependent => :destroy
  has_many :subinterfaces, :as => :interface_template, :class_name => 'VlanTemplate',
           :foreign_key => :interface_template_id, :conditions => { :interface_template_type => 'EthernetTemplate' }

  # Template instances
  has_many :ethernets, :dependent => :destroy
  has_many :instances, :class_name => 'Ethernet', :foreign_key => :ethernet_template_id

  somehow_has :many => :access_points, :through => :access_point_template

  before_save do |record|
    record.related_access_points.each{|ap| ap.outdate_configuration!} if record.new_record? || record.changed?
  end

  after_destroy do |record|
    record.related_access_points.each{|ap| ap.outdate_configuration!}
  end

  before_create do |record|
    record.l2tc_template = L2tcTemplate.new( :shapeable_template => record,
                                             :access_point_template => record.access_point_template)
  end

  # Update linked template instances 
  after_create do |record|
    # We have a new ethernet_template
    record.access_point_template.access_points.each do |h|
      # For each linked template instance, create a new ethernet and associate it with
      # the corresponding access_point
      ne = h.ethernets.build( :machine => h )
      ne.link_to_template( record )
      unless ne.save
        errors.add_to_base(:cannot_update_linked_instances)
      end
    end
  end

  after_save do |record|
    # Are we saving after a change of bridging status?
    if record.bridge_template_id_changed?
      # Ethernet changed bridging status/bridge
      record.instances.each do |e|
        # For each linked template instance, opportunely change its bridging status
        if record.bridge_template.nil?
          e.do_unbridge!
        else
          e.do_bridge!(e.machine.bridges.find(:first, :conditions => "bridge_template_id = #{record.bridge_template.id}"))
        end
      end
    end
  end

  def do_bridge!(b)
    self.bridge_template = b
    self.save!
  end

  def do_unbridge!
    self.bridge_template = nil
    self.save!
  end

  # Accessor methods (read)
  def friendly_name
    self.name
  end
end
