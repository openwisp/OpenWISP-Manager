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

class Operator < ActiveRecord::Base
  acts_as_authentic
  acts_as_authorization_subject
  acts_as_authorization_object :subject_class_name => 'Operator'

  belongs_to :wisp

  # The hidden roles (that give superadmin powers)
  HIDDEN_ROLES = [
      :wisps_viewer, :wisps_creator, :wisps_manager, :wisps_destroyer
  ]

  ROLES = [
      :wisp_viewer, :wisp_manager,

      :operators_viewer, :operators_creator,:operators_manager, :operators_destroyer,

      :access_points_creator, :access_points_viewer, :access_points_manager, :access_points_destroyer,

      :access_point_templates_creator, :access_point_templates_viewer,
      :access_point_templates_manager, :access_point_templates_destroyer,

      :access_point_groups_creator, :access_point_groups_viewer, :access_point_groups_manager,
      :access_point_groups_destroyer,

      :access_points_custom_scripts_creator, :access_points_custom_scripts_manager,
      :access_points_custom_scripts_destroyer,

      :servers_viewer, :servers_creator, :servers_manager, :servers_destroyer,
      
      :ca_manager
  ]

  def roles
    @rs = []
    Operator::ROLES.each do |r|
      @rs << r if self.has_role?(r)
    end
    @rs
  end

  def roles=(new_roles)
    to_remove = self.roles - new_roles
    to_remove.each do |role|
      self.has_no_role!(role, self.wisp) if self.wisp
      self.has_no_role!(role)
    end

    new_roles.map! { |role| role.to_sym }
    new_roles.each do |role|
      if Operator::ROLES.include? role
        self.wisp ? self.has_role!(role, self.wisp) : self.has_role!(role)
      end
    end
  end
end
