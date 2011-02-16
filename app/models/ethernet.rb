class Ethernet < ActiveRecord::Base
  acts_as_authorization_object :subject_class_name => 'Operator'

  acts_as_markable_on_change :watch_for => [
      :output_band, :vlans
  ]

  validates_presence_of :name,
    :unless => Proc.new { |b| b.belongs_to_access_point? and b.name.nil? }
  validates_uniqueness_of :name, :scope => [ :machine_id, :machine_type ],
    :unless => Proc.new { |b| b.belongs_to_access_point? and b.name.nil? }
  validates_format_of :name, :with => /\A[a-z][\w\d_\.]*\Z/i,
    :unless => Proc.new { |b| b.belongs_to_access_point? and b.name.nil? }
  validates_length_of :name, :maximum => 8,
    :unless => Proc.new { |b| b.belongs_to_access_point? and b.name.nil? }

  belongs_to :bridge
  belongs_to :machine, :polymorphic => true, :touch => true

  has_many :vlans, :as => :interface, :dependent => :destroy
  has_many :subinterfaces, :as => :interface, :class_name => 'Vlan', 
    :foreign_key => 'interface_id', :conditions => { :interface_type => 'Ethernet' }
  has_one :l2tc, :as => :shapeable, :dependent => :destroy

  # Instance template
  belongs_to :ethernet_template
  belongs_to :template, :class_name => 'EthernetTemplate', :foreign_key => :ethernet_template_id

  def belongs_to_access_point?
    self.machine.class == AccessPoint
  end
  
  def link_to_template(t)
    self.template = t

    # Create (and link to appropriate templates) subinterfaces (i.e.: vlans)
    t.vlan_templates.each do |vt|
      nv = self.vlans.build( :interface => self  )
      nv.link_to_template( vt )
      unless nv.save!
        raise ActiveRecord::Rollback
      end
    end

    # Create a new l2tc profile for this interface
    nl = self.l2tc = L2tc.new( :access_point => self.machine, :shapeable => self )
    nl.link_to_template(template.l2tc_template)
    unless nl.save!
      raise ActiveRecord::Rollback
    end
  end

  def do_bridge!(b)
    self.bridge = b
    self.save!
  end

  def do_unbridge!
    self.bridge = nil
    self.save!
  end

  # Accessor methods (read)
  def name
    if (read_attribute(:name).blank? or read_attribute(:name).nil?) and !template.nil?
      return template.name
    end

    read_attribute(:name)
  end

  def friendly_name
    self.name
  end

  def output_band
    if (read_attribute(:output_band).blank? or read_attribute(:output_band).nil?) and !template.nil?
      return template.output_band
    end

    read_attribute(:output_band)
  end
  
end
