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

class VlanTemplate < ActiveRecord::Base
  acts_as_authorization_object :subject_class_name => 'Operator'

  validates_uniqueness_of :tag, :scope => [:interface_template_id, :interface_template_type]
  validates_numericality_of :tag,
                            :greater_than_or_equal_to => 1,
                            :less_than_or_equal_to => 4094

  belongs_to :bridge_template

  belongs_to :interface_template, :polymorphic => true

  # Template instances
  has_many :vlans, :dependent => :destroy
  has_many :instances, :class_name => 'Vlan', :foreign_key => :vlan_template_id

  somehow_has :many => :access_points, :through => :interface_template

  after_save :outdate_configuration_if_required
  after_destroy :outdate_configuration_if_required

  # Update linked template instances
  after_create do |record|
    # We have a new vlan_template
    record.interface_template.instances.each do |i|
      # For each linked template instance, create a new vlan and associate it with
      # the corresponding access_point
      nv = i.vlans.build()
      nv.link_to_template(record)
      nv.save!
    end
  end

  after_save do |record|
    # Are we saving after a change of bridging status?
    if record.bridge_template_id_changed?
      # Vlan changed bridging status/bridge
      record.instances.each do |v|
        # For each linked template instance, opportunely change its bridging status
        if record.bridge_template.nil?
          v.do_unbridge!
        else
          v.do_bridge!(v.interface.machine.bridges.find(
                           :first,
                           :conditions => "bridge_template_id = #{record.bridge_template.id}"))
        end
      end
    end
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

  # The name of a vlan is (by default) <interface name>.<vlan tag>
  def name
    "#{self.interface_template.name}.#{self.tag}"
  end

  def friendly_name
    "vlan #{self.tag} - #{self.interface_template.friendly_name}"
  end

  private

  OUTDATING_ATTRIBUTES = [
      :tag, :output_band_percent, :bridge_template_id, :id
  ]

  def outdate_configuration_if_required
    if destroyed? or OUTDATING_ATTRIBUTES.any? { |attribute| send "#{attribute}_changed?" }
      if related_access_points
        related_access_points.each { |access_point| access_point.outdate_configuration! }
      end
    end
  end

end
