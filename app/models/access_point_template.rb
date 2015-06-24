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

class AccessPointTemplate < ActiveRecord::Base
  acts_as_authorization_object :subject_class_name => 'Operator'

  validates_presence_of :name
  validates_format_of :name, :with => /\A[\w\d_\s\.\-]+\Z/i
  validates_length_of :name, :maximum => 32
  validates_uniqueness_of :name, :scope => :wisp_id

  belongs_to :wisp
  has_and_belongs_to_many :template_groups

  has_many :radio_templates, :dependent => :destroy
  has_many :ethernet_templates, :dependent => :destroy
  has_many :bridge_templates, :dependent => :destroy
  has_many :l2vpn_templates, :dependent => :destroy
  has_many :l2tc_templates, :dependent => :destroy
  has_many :custom_script_templates, :dependent => :destroy

  has_many :tap_templates, :through => :l2vpn_templates
  has_many :vap_templates, :through => :radio_templates

  # Template instances
  has_many :access_points, :dependent => :destroy
  has_many :instances, :class_name => 'AccessPoint', :foreign_key => :access_point_template_id


  def interface_templates
    # TODO: this should return an activerecord array
    self.ethernet_templates + self.tap_templates
  end

  def shapeables
    self.interface_templates
  end

  def vlan_templates
    # TODO: this should return an activerecord array
    (self.ethernet_templates.map { |e| e.vlan_templates } +
        self.tap_templates.map { |t| t.vlan_templates }).flatten
  end
  
  def remove_from_redis_info
    allap=AccessPoint.all(:conditions, [ "access_point_template_id ?", self.id])
    redis_s=Redis.new(:host => wisp.redis_server, :port => wisp.redis_port, :db => wisp.redis_db)
    allap.each do |ap|
      l2vpn_cert=ap.l2vpn_clients
      l2vpn_cert.each do |infocert|
         begin
           cert_id=infocert.id
           #puts infocert.id
           distinguished_name=X509Certificate.find(:first,:conditions => [ "certifiable_id = ?", cert_id]).dn
           commonname=distinguished_name.split("CN=")[1]
           redis_s.del("access_points:"+commonname)
         rescue Exception => e
           puts e.to_s
         end
      end
    end
  end
end
