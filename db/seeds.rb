# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#   
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Major.create(:name => 'Daley', :city => cities.first)


# Create 'admin' user. Login: 'admin', Password: 'admin'
sadmin = Operator.create! :login => 'admin', :password => 'admin', :password_confirmation => 'admin', :notes => 'Superadmin'
# Give to 'admin' superadmin powers :)
sadmin.has_role! 'admin'

# Create 'localhost' server
Server.create! :name => 'localhost', :notes => 'Local machine'
