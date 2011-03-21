class Radio < ActiveRecord::Base
  acts_as_authorization_object :subject_class_name => 'Operator'

  DEFAULT_CHANNEL = 6
  DEFAULT_MODE = "11bg"
  MODES = %w( 11bg 11g 11b 11a 11n )

  MAX_VAPS = 4

  validates_uniqueness_of :name, :scope => :access_point_id, :allow_nil => :true, :allow_blank => true
  validates_format_of :name, :with => /\A[a-z][\s\w\d\.]*\Z/i, :allow_nil => :true, :allow_blank => true
  validates_length_of :name, :maximum => 8, :allow_nil => :true, :allow_blank => true

  has_many :vaps, :dependent => :destroy
  has_many :subinterfaces, :class_name => 'Vap', :foreign_key => :radio_id

  belongs_to :access_point

  has_one :l2tc, :as => :shapeable

  # Instance template
  belongs_to :radio_template
  belongs_to :template, :class_name => 'RadioTemplate', :foreign_key => :radio_template_id

  after_save :outdate_configuration_if_required

  def link_to_template(template)
    self.template = template
    
    # Create an instance for each vap_templates defined on this radio and link
    # it with the appropriate template
    self.template.vap_templates.each do |vt|
      nv = self.vaps.build( )
      nv.link_to_template( vt )

      unless nv.save!
        raise ActiveRecord::Rollback
      end
    end

    # Create a new l2tc profile for this interface
    nl = self.l2tc = L2tc.new( :access_point => self.access_point, :shapeable => self )
    nl.link_to_template(template.l2tc_template)
    unless nl.save!
      raise ActiveRecord::Rollback
    end
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

  def mode
    if (read_attribute(:mode).blank? or read_attribute(:mode).nil?) and !template.nil?
      return template.mode
    end

    read_attribute(:mode)
  end
  
  def channel
    if (read_attribute(:channel).blank? or read_attribute(:channel).nil?) and !template.nil?
      return template.channel
    end

    read_attribute(:channel)
  end

  def output_band
    if (read_attribute(:output_band).blank? or read_attribute(:output_band).nil?) and !template.nil?
      return template.output_band
    end

    read_attribute(:output_band)
  end

  private

  def outdate_configuration_if_required
    access_point.outdate_configuration! if access_point && (new_record? || changed? || destroyed?)
  end
end
