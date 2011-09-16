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

class L2vpnClient < ActiveRecord::Base
  acts_as_authorization_object :subject_class_name => 'Operator'

  has_one :tap, :as => :l2vpn, :dependent => :destroy
  has_one :x509_certificate, :as => :certifiable, :dependent => :destroy
  belongs_to :access_point

  belongs_to :l2vpn_template
  belongs_to :template, :class_name => 'L2vpnTemplate', :foreign_key => :l2vpn_template_id

  belongs_to :l2vpn_server

  after_save :outdate_configuration_if_required
  after_destroy :outdate_configuration_if_required

  after_create do |record|
    record.access_point.wisp.ca.create_openvpn_client_certificate(record)
  end

  def self.identifier_prefix
    table_name.singularize
  end

  def self.find_by_identifier(query_str)
    /#{identifier_prefix}_(.+)_(.+)_(.+)/.match(query_str)

    found = self.find($3)

    if found && found.access_point.id.to_s == $2 && found.access_point.wisp.id.to_s == $1
      found
    else
      nil
    end
  end

  def link_to_template(template)
    self.l2vpn_template = template

    unless self.l2vpn_template.tap_template.nil?
      self.tap = Tap.new(:l2vpn => self)
      self.tap.link_to_template(self.l2vpn_template.tap_template)
      self.tap.save
    end
  end

  # Certifiable interface
  def identifier
    "#{L2vpnClient.identifier_prefix}_#{self.access_point.wisp.id}_#{self.access_point.id}_#{self.id}"
  end

  # Accessor methods (read)
  def machine
    self.access_point
  end

  def l2vpn_server
    if (read_attribute(:l2vpn_server_id).blank? or read_attribute(:l2vpn_server_id).nil?) and !template.nil?
      return template.l2vpn_server
    end

    L2vpnServer.find(read_attribute(:l2vpn_server_id))
  end

  def name
    l2vpn_server.name
  end

  def to_xml(options = {}, &block)
    options.merge!(:only => :id, :methods => :identifier)
    super
  end

  private

  OUTDATING_ATTRIBUTES = [:l2vpn_server_id]

  def outdate_configuration_if_required
    if destroyed? or OUTDATING_ATTRIBUTES.any? { |attribute| send "#{attribute}_changed?" }
      access_point.outdate_configuration! if access_point
    end
  end

end
