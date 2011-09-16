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

require 'openssl'

class X509Certificate < ActiveRecord::Base
  acts_as_authorization_object :subject_class_name => 'Operator'

  validates_presence_of :dn, :certificate, :key

  belongs_to :ca
  belongs_to :certifiable, :polymorphic => true

  somehow_has :one => :access_point, :through => :certifiable, :if => Proc.new { |instance| instance.is_a? AccessPoint }
  somehow_has :many => :access_points, :through => :certifiable, :if => Proc.new { |instance| instance.is_a? AccessPoint }

  after_save    :outdate_configuration_if_required
  after_destroy :outdate_configuration_if_required

  def x509_valid?
    !revoked? and !expired?
  end

  def revoked?
    self.revoked == true
  end

  def expired?
    c = OpenSSL::X509::Certificate.new(self.certificate)
    c.not_after < Time.now
  end

  def revoke!
    self.ca.revoke!(self.id)
  end

  def expiry_date
    OpenSSL::X509::Certificate.new(self.certificate).not_after
  end

  def to_text
    c = OpenSSL::X509::Certificate.new(self.certificate)
    c.to_text
  end

  private

  OUTDATING_ATTRIBUTES = [:dn, :certificate, :key, :id]

  def outdate_configuration_if_required
    if destroyed? or OUTDATING_ATTRIBUTES.any? { |attribute| send "#{attribute}_changed?" }
      related_access_point.outdate_configuration! if related_access_point
      related_access_points.each { |access_point| access_point.outdate_configuration! } if related_access_points
    end
  end

end
