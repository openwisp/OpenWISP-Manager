# This file is part of the OpenWISP Manager
#
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
  validates_format_of :site_url, :with => URI::regexp(%w(http https)), :allow_blank => true
  validates_format_of :owmw_url, :with => URI::regexp(%w(http https)), :allow_blank => true

  has_many :access_points

  belongs_to :wisp

  def to_xml(options = {}, &block)
    options.merge!(:only => [:id, :name, :site_url])
    super
  end
end
