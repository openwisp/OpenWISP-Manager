class RadioTemplate < ActiveRecord::Base
  acts_as_authorization_object :subject_class_name => 'Operator'

  DRIVERS = %w( madwifi-ng mac80211 )
  MADWIFI_NAME_PREFIX = 'wifi'         # Default openWRT (uci) radio name prefix for madwifi-ng
  MADWIFI_PHY_NAME_PREFIX = 'wifi'     # Physical radio name prefix for madwifi-ng
  MAC80211_NAME_PREFIX = 'radio'       # Default openWRT (uci) radio name prefix for mc80211
  MAC80211_PHY_NAME_PREFIX = 'phy'     # Physical radio name prefix for mac80211

  MADWIFI_MODES = %w( 11bg 11b 11g 11a )
  MAC80211_MODES = %w( 11g 11b 11a 11na 11ng )
  A_MODES = %w( 11a 11na )
  BG_MODES = %w( 11b 11g 11bg 11ng )
  MODES = A_MODES + BG_MODES
  A_CHANNELS = %w( 34 36 38 40 42 44 46 48 52 56 60 64 149 153 157 161 )
  BG_CHANNELS = %w( 1 2 3 4 5 6 7 8 9 10 11 12 13 )
  CHANNELS = A_CHANNELS + BG_CHANNELS

  MAX_SLOTS = 4
  MAX_VAPS = 4

  validates_presence_of :driver
  validates_inclusion_of :driver, :in => DRIVERS
  validates_uniqueness_of :driver_slot, :scope => [:access_point_template_id, :driver]
  validates_numericality_of :driver_slot, :less_than => MAX_SLOTS, :greater_than_or_equal_to => 0
  validates_inclusion_of :mode, :in => MADWIFI_MODES, :if => Proc.new { |rt| rt.driver == "madwifi-ng" },
                         :message => :invalid_mode_for_selected_driver
  validates_inclusion_of :mode, :in => MAC80211_MODES, :if => Proc.new { |rt| rt.driver == "mac80211" },
                         :message => :invalid_mode_for_selected_driver
  validates_numericality_of :channel

  has_many :vap_templates, :dependent => :destroy
  has_many :subinterfaces, :class_name => 'VapTemplate', :foreign_key => :radio_template_id

  belongs_to :access_point_template

  has_one :l2tc_template, :as => :shapeable_template, :dependent => :destroy

  # Template instances
  has_many :radios, :dependent => :destroy
  has_many :instances, :class_name => 'Radio', :foreign_key => :radio_template_id

  somehow_has :many => :access_points, :through => :access_point_template

  accepts_nested_attributes_for :vap_templates,
                                :allow_destroy => true,
                                :reject_if => lambda { |a| a.values.all?(&:blank?) }

  after_save :outdate_configuration_if_required
  after_destroy :outdate_configuration_if_required

  before_create do |record|
    record.l2tc_template = L2tcTemplate.new(:shapeable_template => record,
                                            :access_point_template => record.access_point_template)
  end

  # Update linked template instances
  after_create do |record|
    # We have a new radio_template
    record.access_point_template.access_points.each do |h|
      # For each linked template instance, create a new radio and associate it with
      # the corresponding access_point
      nr = h.radios.build(:access_point => h)
      nr.link_to_template(record)
      nr.save!
    end
  end

  after_update do |record|
    if record.channel_changed?
      record.radios.each do |radio|
        radio.channel = nil
        radio.save!
      end
    end
  end

  def self.modes_for_driver(driver)
    case driver
      when 'madwifi-ng' then MADWIFI_MODES
      when 'mac80211' then MAC80211_MODES
      else MODES
    end
  end

  def self.channels_for_mode(mode)
    if A_MODES.include? mode
      A_CHANNELS
    elsif BG_MODES.include? mode
      BG_CHANNELS
    else
      CHANNELS
    end
  end

  # Accessor methods for virtual attributes
  def name
    case driver
      when 'madwifi-ng' then  "#{MADWIFI_NAME_PREFIX}#{driver_slot}"
      when 'mac80211' then    "#{MAC80211_NAME_PREFIX}#{driver_slot}"
      else                    "unsupported#{driver_slot}"
    end
  end

  def physical_device_name
    case driver
      when 'madwifi-ng' then  "#{MADWIFI_PHY_NAME_PREFIX}#{driver_slot}"
      when 'mac80211' then    "#{MAC80211_PHY_NAME_PREFIX}#{driver_slot}"
      else                    "unsupported#{driver_slot}"
    end
  end

  def friendly_name
    self.name
  end

  private

  OUTDATING_ATTRIBUTES = [:driver, :driver_slot, :mode, :channel, :output_band, :id]

  def outdate_configuration_if_required
    if destroyed? or OUTDATING_ATTRIBUTES.any? { |attribute| send "#{attribute}_changed?" }
      if related_access_points
        related_access_points.each { |access_point| access_point.outdate_configuration! }
      end
    end
  end

end
