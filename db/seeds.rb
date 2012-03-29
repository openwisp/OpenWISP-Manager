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

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#   
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Major.create(:name => 'Daley', :city => cities.first)

#Clean up Server model...
puts "Cleaning up Server model (delete_all)..."
Server.delete_all

# Create 'localhost' server
puts "Creating 'localhost' server"
Server.create! :name => 'localhost', :notes => 'Local machine'

######################################## OPERATORS SEED START ###################################################################################
#Clean up Operator model...
puts "Cleaning up Operator model (delete_all)..."
Operator.delete_all

# Create 'admin' user. Login: 'admin', Password: 'admin' and give it admin powers
puts "Creating admin with password admin and assigning to all available ROLES"
admin = Operator.new :login => 'admin', :password => 'admin', :password_confirmation => 'admin', :notes => 'admin'
Operator::ROLES.each { |r| admin.has_role! r }
# Add all the hidden roles (that give superadmin powers)
Operator::HIDDEN_ROLES.each { |r| admin.has_role! r }
admin.save(false)
######################################## OPERATORS SEED END #####################################################################################
