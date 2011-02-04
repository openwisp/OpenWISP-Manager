class AccessPointTemplate < ActiveRecord::Base
  acts_as_authorization_object :subject_class_name => 'Operator'
  
  validates_presence_of :name
  validates_format_of :name, :with => /\A[\w\d_\s\.]+\Z/i
  validates_length_of :name, :maximum => 32
  validates_uniqueness_of :name, :scope => :wisp_id

  belongs_to :wisp
  has_and_belongs_to_many :template_groups

  has_many :radio_templates, :dependent => :destroy
  has_many :ethernet_templates, :dependent => :destroy
  has_many :bridge_templates, :dependent => :destroy
  has_many :l2vpn_templates, :dependent => :destroy
  has_many :l2tc_templates, :dependent => :destroy
  has_many :custom_script_templates, :dependent => :destroy

  has_many :tap_templates, :through => :l2vpn_templates
  has_many :vap_templates, :through => :radio_templates

  # Template instances
  has_many :access_points, :dependent => :destroy
  has_many :instances, :class_name => 'AccessPoint', :foreign_key => :access_point_template_id


  def interface_templates
    # TODO: this should return an activerecord array
    self.ethernet_templates + self.tap_templates
  end

  def shapeables
    self.interface_templates
  end

  def vlan_templates
    # TODO: this should return an activerecord array
    (self.ethernet_templates.map { | e | e.vlan_templates } + 
      self.tap_templates.map { |t| t.vlan_templates }).flatten
  end

end
