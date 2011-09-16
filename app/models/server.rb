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

class Server < ActiveRecord::Base
  validates_uniqueness_of :name
  validates_presence_of :name
  validates_format_of :name, :with => /\A[a-z][\s\w\d\.\-]*\Z/i
  validates_length_of :name, :maximum => 16

  has_many :ethernets, :as => :machine, :dependent => :destroy
  has_many :bridges, :as => :machine, :dependent => :destroy
  has_many :l2vpn_servers, :dependent => :destroy

  has_many :taps, :through => :l2vpn_servers

  somehow_has :many => :access_points, :through => :l2vpn_servers

  def vlans
    # TODO: this should return an activerecord array
    (self.ethernets.map { |e| e.vlans } +
        self.taps.map { |t| t.vlans }).flatten
  end

  def interfaces
    # TODO: this should return an activerecord array
    self.ethernets + self.taps
  end

end
