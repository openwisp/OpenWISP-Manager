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

class TapTemplate < ActiveRecord::Base
  acts_as_authorization_object :subject_class_name => 'Operator'

  belongs_to :bridge_template
  belongs_to :l2vpn_template

  has_one :l2tc_template, :as => :shapeable_template, :dependent => :destroy

  has_many :vlan_templates, :as => :interface_template, :dependent => :destroy
  has_many :subinterfaces, :as => :interface_template, :class_name => 'VlanTemplate',
           :foreign_key => :interface_template_id, :conditions => {:interface_template_type => 'TapTemplate'}

  # Template instances
  has_many :taps, :dependent => :destroy
  has_many :instances, :class_name => 'Tap', :foreign_key => :tap_template_id

  somehow_has :many => :access_points, :through => :l2vpn_template

  after_save :outdate_configuration_if_required
  after_destroy :outdate_configuration_if_required

  before_create do |record|
    record.l2tc_template = L2tcTemplate.new(:shapeable_template => record,
                                            :access_point_template => record.l2vpn_template.access_point_template)
  end

  # Update linked template instances 
  after_create do |record|
    # We have a new tap_template
    record.l2vpn_template.l2vpn_clients.each do |v|
      # For each linked template instance, create a new tap and associate it with
      # the corresponding access_point
      nt = v.tap.build(:l2vpn_client => v)
      nt.link_to_template(record)
      unless nt.save
        errors.add_to_base(:cannot_update_linked_instances)
      end
    end
  end

  after_save do |record|
    # Are we saving after a change of bridging status?
    if record.bridge_template_id_changed?
      # Tap changed bridging status/bridge
      record.instances.each do |t|
        # For each linked template instance, opportunely change its bridging status
        if record.bridge_template.nil?
          t.do_unbridge!
        else
          t.do_bridge!(t.l2vpn.machine.bridges.find(:first, :conditions => "bridge_template_id = #{record.bridge_template.id}"))
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
  def name
    "v#{self.l2vpn_template.id}t#{self.id}"
  end

  def friendly_name
    "layer 2 vpn '#{self.l2vpn_template.l2vpn_server.name}'"
  end

  private

  OUTDATING_ATTRIBUTES = [:bridge_template_id, :output_band, :id]

  def outdate_configuration_if_required
    if destroyed? or OUTDATING_ATTRIBUTES.any? { |attribute| send "#{attribute}_changed?" }
      if related_access_points
        related_access_points.each { |access_point| access_point.outdate_configuration! }
      end
    end
  end

end