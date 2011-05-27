class AccessPointGroup < ActiveRecord::Base
  acts_as_authorization_object :subject_class_name => 'Operator'

  validates_presence_of :name
  validates_format_of :name, :with => /\A[\w\d_\s\.]+\Z/i
  validates_length_of :name, :maximum => 32
  validates_uniqueness_of :name, :scope => :wisp_id
  validates_format_of :site_url, :with => URI::regexp(%w(http https)), :allow_blank => true
  validates_format_of :owmw_url, :with => URI::regexp(%w(http https)), :allow_blank => true

  has_many :access_points

  belongs_to :wisp

  def to_xml(options = {}, &block)
    options.merge!(:only => [:name, :site_url])
    super
  end
end
