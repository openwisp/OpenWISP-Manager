# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_vwispmanager_session',
  :secret      => '3eda61f08d59a4bbbb214c8f384bdc0d04b44f07423a77f68c50474d3744a2ad6e373b604494a275d091086aa70ee99252aa08281a49d2612056132f33ab5169'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
