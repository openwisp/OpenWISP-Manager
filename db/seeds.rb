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
