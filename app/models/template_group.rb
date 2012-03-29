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

class TemplateGroup < ActiveRecord::Base
  acts_as_authorization_object :subject_class_name => 'Operator'

  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :wisp_id
  validates_format_of :name, :with => /\A[\w\d_\.\s]+\Z/i
  validates_length_of :name, :maximum => 32

  has_and_belongs_to_many :access_point_templates

  belongs_to :wisp

end
