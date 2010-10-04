class Wisp < ActiveRecord::Base
  acts_as_authorization_object :subject_class_name => 'Operator'

  validates_uniqueness_of :name

  has_one :ca, :dependent => :destroy

  has_many :operators, :dependent => :destroy
  has_many :template_groups, :dependent => :destroy
  has_many :access_point_groups, :dependent => :destroy
  has_many :access_points, :dependent => :destroy
  has_many :access_point_templates, :dependent => :destroy
  has_many :l2vpn_servers, :dependent => :destroy
  
  accepts_nested_attributes_for :ca 

end
