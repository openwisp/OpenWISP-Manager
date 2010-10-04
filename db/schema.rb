# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100416141506) do

  create_table "access_point_groups", :force => true do |t|
    t.string   "name",       :null => false
    t.text     "notes"
    t.integer  "wisp_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "access_point_groups_access_points", :id => false, :force => true do |t|
    t.integer  "access_point_id"
    t.integer  "access_point_group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "access_point_templates", :force => true do |t|
    t.string   "name",         :null => false
    t.text     "notes"
    t.datetime "committed_at"
    t.integer  "wisp_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "access_point_templates_template_groups", :id => false, :force => true do |t|
    t.integer  "access_point_template_id"
    t.integer  "template_group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "access_points", :force => true do |t|
    t.string   "name",                     :null => false
    t.string   "mac_address"
    t.string   "configuration_md5"
    t.boolean  "internal",                 :null => false
    t.date     "activation_date"
    t.string   "address",                  :null => false
    t.string   "city",                     :null => false
    t.string   "zip",                      :null => false
    t.float    "lat",                      :null => false
    t.float    "lon",                      :null => false
    t.datetime "committed_at"
    t.text     "notes"
    t.integer  "wisp_id"
    t.integer  "access_point_template_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "access_points", ["mac_address"], :name => "index_access_points_on_mac_address"

  create_table "bdrb_job_queues", :force => true do |t|
    t.text     "args"
    t.string   "worker_name"
    t.string   "worker_method"
    t.string   "job_key"
    t.integer  "taken"
    t.integer  "finished"
    t.integer  "timeout"
    t.integer  "priority"
    t.datetime "submitted_at"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.datetime "archived_at"
    t.string   "tag"
    t.string   "submitter_info"
    t.string   "runner_info"
    t.string   "worker_key"
    t.datetime "scheduled_at"
  end

  create_table "bridge_templates", :force => true do |t|
    t.string   "name",                     :null => false
    t.text     "notes"
    t.string   "ip_range_begin"
    t.string   "ip_range_end"
    t.string   "netmask"
    t.string   "gateway"
    t.string   "dns"
    t.string   "addressing_mode",          :null => false
    t.integer  "access_point_template_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bridges", :force => true do |t|
    t.string   "name"
    t.string   "ip"
    t.string   "netmask"
    t.string   "gateway"
    t.string   "dns"
    t.text     "notes"
    t.string   "addressing_mode"
    t.integer  "machine_id"
    t.string   "machine_type"
    t.integer  "bridge_template_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cas", :force => true do |t|
    t.integer  "serial",     :null => false
    t.string   "c",          :null => false
    t.string   "st",         :null => false
    t.string   "l",          :null => false
    t.string   "o",          :null => false
    t.string   "cn",         :null => false
    t.integer  "wisp_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "crl_list"
  end

  create_table "configurations", :force => true do |t|
    t.string   "key",                           :null => false
    t.string   "value",      :default => "",    :null => false
    t.boolean  "system_key", :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "configurations", ["key"], :name => "index_configurations_on_key"

  create_table "custom_script_templates", :force => true do |t|
    t.string   "name"
    t.text     "body"
    t.text     "notes"
    t.string   "cron_minute"
    t.string   "cron_hour"
    t.string   "cron_day"
    t.string   "cron_month"
    t.string   "cron_dayweek"
    t.integer  "access_point_template_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "custom_scripts", :force => true do |t|
    t.string   "name"
    t.text     "body"
    t.text     "notes"
    t.string   "cron_minute"
    t.string   "cron_hour"
    t.string   "cron_day"
    t.string   "cron_month"
    t.string   "cron_dayweek"
    t.integer  "access_point_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ethernet_templates", :force => true do |t|
    t.string   "name"
    t.text     "notes"
    t.integer  "output_band"
    t.integer  "bridge_template_id"
    t.integer  "access_point_template_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ethernets", :force => true do |t|
    t.string   "name"
    t.text     "notes"
    t.integer  "output_band"
    t.integer  "bridge_id"
    t.integer  "machine_id"
    t.string   "machine_type"
    t.integer  "ethernet_template_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "hourly_monitoring_access_points", :force => true do |t|
    t.integer "hour"
    t.date    "date"
    t.integer "access_point_id"
  end

  create_table "l2tc_templates", :force => true do |t|
    t.text     "notes"
    t.integer  "access_point_template_id"
    t.integer  "shapeable_template_id"
    t.string   "shapeable_template_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "l2tcs", :force => true do |t|
    t.text     "notes"
    t.integer  "access_point_id"
    t.integer  "shapeable_id"
    t.string   "shapeable_type"
    t.integer  "l2tc_template_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "l2vpn_clients", :force => true do |t|
    t.boolean  "mtu_test",          :default => false
    t.text     "notes"
    t.integer  "access_point_id"
    t.integer  "l2vpn_server_id"
    t.integer  "l2vpn_template_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "l2vpn_servers", :force => true do |t|
    t.string   "name"
    t.integer  "port",       :null => false
    t.string   "protocol",   :null => false
    t.string   "cipher",     :null => false
    t.text     "tls_auth"
    t.text     "dh"
    t.text     "notes"
    t.string   "ip"
    t.integer  "mtu"
    t.string   "mtu_disc"
    t.integer  "server_id"
    t.integer  "wisp_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "l2vpn_templates", :force => true do |t|
    t.text     "notes"
    t.integer  "access_point_template_id"
    t.integer  "l2vpn_server_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "operators", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "login",                            :null => false
    t.string   "crypted_password",                 :null => false
    t.string   "password_salt",                    :null => false
    t.string   "persistence_token",                :null => false
    t.integer  "login_count",       :default => 0, :null => false
    t.datetime "last_request_at"
    t.datetime "last_login_at"
    t.datetime "current_login_at"
    t.string   "last_login_ip"
    t.string   "current_login_ip"
    t.text     "notes"
    t.integer  "wisp_id"
  end

  add_index "operators", ["last_request_at"], :name => "index_operators_on_last_request_at"
  add_index "operators", ["login"], :name => "index_operators_on_login"
  add_index "operators", ["persistence_token"], :name => "index_operators_on_persistence_token"

  create_table "operators_roles", :id => false, :force => true do |t|
    t.integer  "operator_id"
    t.integer  "role_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "radio_templates", :force => true do |t|
    t.string   "name",                     :null => false
    t.string   "mode",                     :null => false
    t.integer  "channel",                  :null => false
    t.text     "notes"
    t.integer  "output_band"
    t.integer  "access_point_template_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "radios", :force => true do |t|
    t.string   "name"
    t.string   "mode"
    t.integer  "channel"
    t.text     "notes"
    t.integer  "output_band"
    t.integer  "access_point_id"
    t.integer  "radio_template_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles", :force => true do |t|
    t.string   "name",              :limit => 40
    t.string   "authorizable_type", :limit => 40
    t.integer  "authorizable_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "servers", :force => true do |t|
    t.string   "name"
    t.text     "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tap_templates", :force => true do |t|
    t.text     "notes"
    t.integer  "output_band"
    t.integer  "l2vpn_template_id"
    t.integer  "bridge_template_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "taps", :force => true do |t|
    t.text     "notes"
    t.integer  "output_band"
    t.integer  "l2vpn_id"
    t.string   "l2vpn_type"
    t.integer  "bridge_id"
    t.integer  "tap_template_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "template_groups", :force => true do |t|
    t.string   "name",       :null => false
    t.text     "notes"
    t.integer  "wisp_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "vap_templates", :force => true do |t|
    t.text     "notes"
    t.integer  "output_band_percent"
    t.string   "essid"
    t.string   "visibility"
    t.string   "encryption"
    t.string   "key"
    t.string   "radius_auth_server"
    t.integer  "radius_auth_server_port"
    t.string   "radius_acct_server"
    t.integer  "radius_acct_server_port"
    t.integer  "radio_template_id"
    t.integer  "bridge_template_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "vaps", :force => true do |t|
    t.text     "notes"
    t.integer  "output_band_percent"
    t.string   "essid"
    t.string   "visibility"
    t.string   "encryption"
    t.string   "key"
    t.string   "radius_auth_server"
    t.integer  "radius_auth_server_port"
    t.string   "radius_acct_server"
    t.integer  "radius_acct_server_port"
    t.integer  "radio_id"
    t.integer  "bridge_id"
    t.integer  "vap_template_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "vlan_templates", :force => true do |t|
    t.text     "notes"
    t.integer  "output_band_percent"
    t.integer  "tag"
    t.integer  "interface_template_id"
    t.string   "interface_template_type"
    t.integer  "bridge_template_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "vlans", :force => true do |t|
    t.text     "notes"
    t.integer  "output_band_percent"
    t.integer  "tag"
    t.integer  "interface_id"
    t.string   "interface_type"
    t.integer  "bridge_id"
    t.integer  "vlan_template_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "weekly_monitoring_access_points", :force => true do |t|
    t.date    "date"
    t.integer "percentage"
    t.integer "access_point_id"
  end

  create_table "wisps", :force => true do |t|
    t.string   "name",       :null => false
    t.text     "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "x509_certificates", :force => true do |t|
    t.string   "dn",                                   :null => false
    t.text     "certificate",                          :null => false
    t.text     "key",                                  :null => false
    t.boolean  "revoked",           :default => false
    t.integer  "ca_id"
    t.integer  "certificable_id"
    t.string   "certificable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
