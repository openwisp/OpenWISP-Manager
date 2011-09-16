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

class Vlan < ActiveRecord::Base
  acts_as_authorization_object :subject_class_name => 'Operator'

  validates_uniqueness_of :tag, :scope => :interface_id,
                          :unless => Proc.new { |b| b.interface.is_a?(AccessPoint) and b.tag.nil? }
  validates_numericality_of :tag,
                            :greater_than_or_equal_to => 1,
                            :less_than_or_equal_to => 4094,
                            :unless => Proc.new { |b| b.interface.is_a?(AccessPoint) and b.tag.nil? }

  belongs_to :interface, :polymorphic => true

  belongs_to :bridge

  # Instance template
  belongs_to :vlan_template
  belongs_to :template, :class_name => 'VlanTemplate', :foreign_key => :vlan_template_id

  somehow_has :one => :machine, :through => :interface, :as => :related_access_point, :if => Proc.new { |instance| instance.is_a? AccessPoint }

  after_save :outdate_configuration_if_required

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
    if read_attribute(:tag).blank? and !template.nil?
      return template.tag
    end

    read_attribute(:tag)
  end

  def name
    "#{self.interface.name}.#{self.tag}"
  end

  def friendly_name
    "vlan #{self.tag} - #{self.interface.friendly_name}"
  end

  def output_band_percent
    if read_attribute(:output_band_percent).blank? and !template.nil?
      return template.output_band_percent
    end

    read_attribute(:output_band_percent)
  end

  def machine
    self.interface.machine
  end

  def output_band
    if self.interface.output_band.blank? or self.output_band_percent.blank?
      nil
    else
      self.interface.output_band * self.output_band_percent / 100
    end
  end

  def tc_protocol
    '802.1q'
  end

  private

  OUTDATING_ATTRIBUTES = [:tag, :output_band_percent, :bridge_id]

  def outdate_configuration_if_required
    if destroyed? or OUTDATING_ATTRIBUTES.any? { |attribute| send "#{attribute}_changed?" }
      related_access_point.outdate_configuration! if related_access_point
    end
  end

end
