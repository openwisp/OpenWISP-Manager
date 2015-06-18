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

class AccessPointGroup < ActiveRecord::Base
  acts_as_authorization_object :subject_class_name => 'Operator'

  validates_presence_of :name
  validates_format_of :name, :with => /\A[\w\d_\s\.]+\Z/i
  validates_length_of :name, :maximum => 32
  validates_uniqueness_of :name, :scope => :wisp_id
  validates_format_of :owmw_url, :with => URI::regexp(%w(http https)), :allow_blank => true
  # Site_url could be an http(s) URI or a parameter
  validates_format_of :site_url, :with => /\A[[:print:]]+\Z/, :allow_blank => true

  has_many :access_points

  belongs_to :wisp
  
  def remove_from_redis_info
    redis_s=Redis.new(:host => "test4.inroma.roma.it", :port => 6379, :db => 0)
    allap=AccessPoint.all(:conditions => [ "access_point_group_id = ?", self.id ])
    allap.each do | ap |
       macaddress=ap.mac_address
       name=ap.name
       l2vpn_cert=ap.l2vpn_clients
       l2vpn_cert.each do |infocert|
          begin
            cert_id=infocert.id
            #puts infocert.id
            distinguished_name=X509Certificate.find(:first,:conditions => [ "certifiable_id = ?", cert_id]).dn
            commonname=distinguished_name.split("CN=")[1]
            redis_s.hdel("access_points:"+commonname, "URL")
         rescue Exception => e
            puts e.to_s 
	 end
       end
     end
  end

  def to_xml(options = {}, &block)
    options.merge!(:only => [:id, :name, :site_url])
    super
  end
end
