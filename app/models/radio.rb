# This file is part of the OpenWISP Manager
#
# Copyright (C) 2012 OpenWISP.org
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

class Radio < ActiveRecord::Base
  acts_as_authorization_object :subject_class_name => 'Operator'

  DRIVERS = %w( madwifi-ng mac80211 )
  MADWIFI_NAME_PREFIX = 'wifi' # Default openWRT (uci) radio name prefix for madwifi-ng
  MADWIFI_PHY_NAME_PREFIX = 'wifi' # Physical radio name prefix for madwifi-ng
  MAC80211_NAME_PREFIX = 'radio' # Default openWRT (uci) radio name prefix for mc80211
  MAC80211_PHY_NAME_PREFIX = 'phy' # Physical radio name prefix for mac80211

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


  validates_inclusion_of :driver, :in => DRIVERS, :allow_blank => true
  validates_uniqueness_of :driver_slot, :scope => [:access_point_id, :driver], :allow_blank => true
  validates_numericality_of :driver_slot, :less_than => MAX_SLOTS, :greater_than_or_equal_to => 0, :allow_blank => true
  validates_inclusion_of :mode, :in => MADWIFI_MODES, :if => Proc.new { |r| r.driver == "madwifi-ng" },
                         :message => :invalid_mode_for_selected_driver, :allow_blank => true
  validates_inclusion_of :mode, :in => MAC80211_MODES, :if => Proc.new { |r| r.driver == "mac80211" },
                         :message => :invalid_mode_for_selected_driver, :allow_blank => true
  validates_numericality_of :channel

  has_many :vaps, :dependent => :destroy
  has_many :subinterfaces, :class_name => 'Vap', :foreign_key => :radio_id

  belongs_to :access_point

  has_one :l2tc, :as => :shapeable

  # Instance template
  belongs_to :radio_template
  belongs_to :template, :class_name => 'RadioTemplate', :foreign_key => :radio_template_id

  after_save :outdate_configuration_if_required
  after_destroy :outdate_configuration_if_required

  def link_to_template(template)
    self.template = template

    # Create an instance for each vap_templates defined on this radio and link
    # it with the appropriate template
    self.template.vap_templates.each do |vt|
      nv = self.vaps.build()
      nv.link_to_template(vt)

      unless nv.save!
        raise ActiveRecord::Rollback
      end
    end

    # Create a new l2tc profile for this interface
    nl = self.l2tc = L2tc.new(:access_point => self.access_point, :shapeable => self)
    nl.link_to_template(template.l2tc_template)
    unless nl.save!
      raise ActiveRecord::Rollback
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

  # Accessor methods for virtual attributes and inherited attributes
  def name
    case driver
      when 'madwifi-ng' then
        "#{MADWIFI_NAME_PREFIX}#{driver_slot}"
      when 'mac80211' then
        "#{MAC80211_NAME_PREFIX}#{driver_slot}"
      else
        "unsupported#{driver_slot}"
    end
  end

  def physical_device_name
    case driver
      when 'madwifi-ng' then
        "#{MADWIFI_PHY_NAME_PREFIX}#{driver_slot}"
      when 'mac80211' then
        "#{MAC80211_PHY_NAME_PREFIX}#{driver_slot}"
      else
        "unsupported#{driver_slot}"
    end
  end

  def friendly_name
    self.name
  end

  def driver
    if read_attribute(:driver).blank? and !template.nil?
      return template.driver
    end

    read_attribute(:driver)
  end

  def driver_slot
    if read_attribute(:driver_slot).blank? and !template.nil?
      return template.driver_slot
    end

    read_attribute(:driver_slot)
  end

  def mode
    if read_attribute(:mode).blank? and !template.nil?
      return template.mode
    end

    read_attribute(:mode)
  end

  def channel
    if read_attribute(:channel).blank? and !template.nil?
      return template.channel
    end

    read_attribute(:channel)
  end

  def output_band
    if read_attribute(:output_band).blank? and !template.nil?
      return template.output_band
    end

    read_attribute(:output_band)
  end

  private

  OUTDATING_ATTRIBUTES = [:driver, :driver_slot, :mode, :channel, :output_band]

  def outdate_configuration_if_required
    if destroyed? or OUTDATING_ATTRIBUTES.any? { |attribute| send "#{attribute}_changed?" }
      access_point.outdate_configuration! if access_point
    end
  end

end
