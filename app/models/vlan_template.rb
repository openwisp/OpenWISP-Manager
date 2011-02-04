class VlanTemplate < ActiveRecord::Base
  acts_as_authorization_object :subject_class_name => 'Operator'

  validates_uniqueness_of :tag, :scope => [ :interface_template_id, :interface_template_type ]
  validates_numericality_of :tag,
                            :greater_than_or_equal_to => 1,
                            :less_than_or_equal_to => 4094

  belongs_to :bridge_template

  belongs_to :interface_template, :polymorphic => true, :touch => true

  # Template instances
  has_many :vlans, :dependent => :destroy
  has_many :instances, :class_name => 'Vlan', :foreign_key => :vlan_template_id

  # Update linked template instances
  after_create { |record|
  # We have a new vlan_template
    record.interface_template.instances.each do |i|
      # For each linked template instance, create a new vlan and associate it with
      # the corresponding access_point
      nv = i.vlans.build( )
      nv.link_to_template( record )
      nv.save!
    end
  }

  after_save { |record|
  # Are we saving after a change of bridging status?
    if record.bridge_template_id_changed?
      # Vlan changed bridging status/bridge
      record.instances.each do |v|
        # For each linked template instance, opportunely change its bridging status
        if record.bridge_template.nil?
          v.do_unbridge!
        else
          v.do_bridge!(v.interface.machine.bridges.find(
                           :first,
                           :conditions => "bridge_template_id = #{record.bridge_template.id}"))
        end
      end
    end
  }

  def do_bridge!(b)
    self.bridge_template = b
    self.save!
  end

  def do_unbridge!
    self.bridge_template = nil
    self.save!
  end

  # Accessor methods (read)

  # The name of a vlan is (by default) <interface name>.<vlan tag>
  def name
    "#{self.interface_template.name}.#{self.tag}"
  end

  def friendly_name
    "vlan #{self.tag} - #{self.interface_template.friendly_name}"
  end

end
