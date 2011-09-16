# This file is part of the OpenWISP Manager
#
# Copyright (C) 2010 CASPUR (wifi@caspur.it)
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

class VapTemplate < ActiveRecord::Base
  acts_as_authorization_object :subject_class_name => 'Operator'

  NAME_PREFIX = "vap"

  ENC_TYPES = %w(none wep psk psk2 wpa wpa2 pskmixed wpamixed)
  ENC_TYPES_SELECT = {
      'none' => 'none',
      'WEP' => 'wep',
      'WPA psk' => 'psk',
      'WPA2 psk' => 'psk2',
      'WPA 802.1x' => 'wpa',
      'WPA2 802.1x' => 'wpa2',
      'WPA/WPA2 psk' => 'pskmixed',
      'WPA/WPA2 802.1x' => 'wpamixed'
  }
  ENC_TYPES_FSELECT = {
      'none' => 'none',
      'wep' => 'WEP',
      'psk' => 'WPA psk',
      'psk2' => 'WPA2 psk',
      'wpa' => 'WPA 802.1x',
      'wpa2' => 'WPA2 802.1x',
      'pskmixed' => 'WPA/WPA2 psk',
      'wpamixed' => 'WPA/WPA2 802.1x'
  }
  ENC_TYPES_WKEY = %w(wep psk psk2 wpa wpa2 pskmixed wpamixed)
  ENC_TYPES_WRADIUS = %w(wpa wpa2 wpamixed)

  VISIBILITIES = %w(hidden broadcasted)
  VISIBILITIES_SELECT = {
      'Hidden' => 'hidden',
      'Broadcasted' => 'broadcasted'
  }
  VISIBILITIES_FSELECT = {
      'hidden' => 'Hidden',
      'broadcasted' => 'Broadcasted'
  }

  validates_presence_of :essid
  validates_format_of :essid, :with => /\A[\s\w\d\._\-]+\Z/i
  validates_length_of :essid, :maximum=>32

  validates_inclusion_of :visibility, :in => VapTemplate::VISIBILITIES

  validates_inclusion_of :encryption, :in => VapTemplate::ENC_TYPES

  validates_presence_of :key, :if => :key_needed?
  validates_format_of :key, :with => /\A[\s\w\d\._]+\Z/i, :if => :key_needed?
  validates_length_of :key, :maximum=>128, :if => :key_needed?

  validates_presence_of :radius_auth_server, :if => :radius_needed?
  validates_format_of :radius_auth_server,
                      :with => /\A[\w\d\.]+\Z/i,
                      :if => :radius_needed?
  validates_length_of :radius_auth_server,
                      :maximum=>128,
                      :if => :radius_needed?
  validates_presence_of :radius_auth_server_port, :if => :radius_needed?
  validates_numericality_of :radius_auth_server_port,
                            :only_integer => true,
                            :greater_than => 0,
                            :less_than_or_equal_to => 65535,
                            :if => :radius_needed?

  validates_format_of :radius_acct_server, :with => /\A[\w\d\.]+\Z/i,
                      :allow_nil => true, :allow_blank => true
  validates_length_of :radius_acct_server, :maximum=>128,
                      :allow_nil => true, :allow_blank => true
  validates_numericality_of :radius_acct_server_port,
                            :only_integer => true,
                            :greater_than => 0,
                            :less_than_or_equal_to => 65535,
                            :allow_nil => true, :allow_blank => true

  belongs_to :bridge_template
  belongs_to :radio_template

  # Template instances
  has_many :vaps, :dependent => :destroy
  has_many :instances, :class_name => 'Vap', :foreign_key => :vap_template_id

  somehow_has :many => :access_points, :through => :radio_template

  after_save :outdate_configuration_if_required

  # Update linked template instances
  after_create do |record|
    # We have a new vap_template
    record.radio_template.radios.each do |r|
      # For each linked template instance, create a new vap and associate it with
      # the corresponding access_point
      nv = r.vaps.build(:radio => r)
      nv.link_to_template(record)
      nv.save!
    end
  end

  after_save do |record|
    # Are we saving after a change of bridging status?
    if record.bridge_template_id_changed?
      # Vap changed bridging status/bridge
      record.instances.each do |v|
        # For each linked template instance, opportunely change its bridging status
        if record.bridge_template.nil?
          v.do_unbridge!
        else
          v.do_bridge!(v.radio.access_point.bridges.find(
                           :first,
                           :conditions => "bridge_template_id = #{record.bridge_template.id}"))
        end
      end
    end
  end

  def key_needed?
    VapTemplate::ENC_TYPES_WKEY.include?(encryption)
  end

  def radius_needed?
    VapTemplate::ENC_TYPES_WRADIUS.include?(encryption)
  end

  def do_bridge!(b)
    self.bridge_template = b
    self.save!
  end

  def do_unbridge!
    self.bridge_template = nil
    self.save!
  end

  # Accessor methods (read)
  def name
    "r#{self.radio_template.id}v#{self.id}"
  end

  def friendly_name
    "essid '#{self.essid}' - radio '#{self.radio_template.name}'"
  end

  private

  OUTDATING_ATTRIBUTES = [
      :essid, :visibility, :encryption, :key, :radius_auth_server, :radius_acct_server,
      :output_band_percent, :bridge_template_id, :id
  ]

  def outdate_configuration_if_required
    if destroyed? or OUTDATING_ATTRIBUTES.any? { |attribute| send "#{attribute}_changed?" }
      if related_access_points
        related_access_points.each { |access_point| access_point.outdate_configuration! }
      end
    end
  end

end
