class Vlan < ActiveRecord::Base
  acts_as_authorization_object :subject_class_name => 'Operator'

  validates_uniqueness_of :tag, :scope => :interface_id,
    :unless => Proc.new { |b| b.belongs_to_access_point? and b.tag.nil? }
  validates_numericality_of :tag, :greater_than_or_equal_to => 1, :less_than_or_equal_to => 4094,
    :unless => Proc.new { |b| b.belongs_to_access_point? and b.tag.nil? }
  
  belongs_to :interface, :polymorphic => true, :touch => true
  
  belongs_to :bridge
  
  # Instance template
  belongs_to :vlan_template
  belongs_to :template, :class_name => 'VlanTemplate', :foreign_key => :vlan_template_id

  def belongs_to_access_point?
    return self.machine.class == AccessPoint
  end

  def link_to_template(t)
    self.template = t
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

  def tag
    if (read_attribute(:tag).blank? or read_attribute(:tag).nil?) and !template.nil?
      return template.tag
    end

    return read_attribute(:tag)
  end
  
  def name
    "#{self.interface.name}.#{self.tag}"
  end

  def friendly_name
    "vlan #{self.tag} - #{self.interface.friendly_name}"
  end

  def output_band_percent
    if (read_attribute(:output_band_percent).blank? or read_attribute(:output_band_percent).nil?) and !template.nil?
      return template.output_band_percent
    end

    return read_attribute(:output_band_percent)
  end

  def machine
    return self.interface.machine
  end

  def output_band
    if self.interface.output_band.nil? or self.output_band_percent.nil?
      nil
    else
      self.interface.output_band * self.output_band_percent / 100
    end
  end

  def tc_protocol
    '802.1q'
  end

end
