class Wisp < ActiveRecord::Base
  include Addons::Mappable

  acts_as_authorization_object :subject_class_name => 'Operator'

  validates_uniqueness_of :name
  validates_format_of :name, :with => /\A[a-z][\s\w\d\._']*\Z/i
  validates_format_of :owmw_url, :with => URI::regexp(%w(http https)), :allow_blank => true
  validates_length_of :name, :maximum => 32

  has_one :ca, :dependent => :destroy

  has_many :operators, :dependent => :destroy
  has_many :template_groups, :dependent => :destroy
  has_many :access_point_groups, :dependent => :destroy
  has_many :access_points, :dependent => :destroy
  has_many :access_point_templates, :dependent => :destroy
  has_many :l2vpn_servers, :dependent => :destroy

  accepts_nested_attributes_for :ca

  def geocode
    get_wisp_geocode "#{ca.l}, #{ca.st}, #{ca.c}"
  end
end
