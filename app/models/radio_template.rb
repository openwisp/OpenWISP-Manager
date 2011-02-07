class RadioTemplate < ActiveRecord::Base
  acts_as_authorization_object :subject_class_name => 'Operator'

  NAME_PREFIX = 'wifi'

  DEFAULT_CHANNEL = 6
  DEFAULT_MODE = "11bg"
  MODES = %w( 11bg 11g 11b 11a )

  MAX_VAPS = 4

  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :access_point_template_id
  validates_format_of :name, :with => /\A[a-z][\s\w\d\.]*\Z/i
  validates_length_of :name, :maximum => 8

  has_many :vap_templates, :dependent => :destroy
  has_many :subinterfaces, :class_name => 'VapTemplate', :foreign_key => :radio_template_id

  belongs_to :access_point_template, :touch => true

  has_one :l2tc_template, :as => :shapeable_template, :dependent => :destroy

  # Template instances
  has_many :radios, :dependent => :destroy
  has_many :instances, :class_name => 'Radio', :foreign_key => :radio_template_id

  accepts_nested_attributes_for :vap_templates,
                                :allow_destroy => true,
                                :reject_if => lambda { |a| a.values.all?(&:blank?) }

  before_create do |record|
    record.l2tc_template = L2tcTemplate.new( :shapeable_template => record,
                                             :access_point_template => record.access_point_template)
  end

  # Update linked template instances
  after_create do |record|
  # We have a new radio_template
    record.access_point_template.access_points.each do |h|
      # For each linked template instance, create a new radio and associate it with
      # the corresponding access_point
      nr = h.radios.build( :access_point => h )
      nr.link_to_template( record )
      nr.save!
    end
  end

  def initialize(params = nil)
    super(params)
    self.channel = DEFAULT_CHANNEL if self.channel.nil?
    self.mode = DEFAULT_MODE if self.mode.nil?
  end

  # Accessor methods (read)
  def friendly_name
    self.name
  end

end
