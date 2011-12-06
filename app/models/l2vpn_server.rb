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

class L2vpnServer < ActiveRecord::Base

  DEFAULT_PROTOCOL = "udp"
  DEFAULT_CIPHER = "AES-128-CBC"

  PROTOCOLS_SELECT = {
      "udp" => "udp",
      "tcp" => "tcp"
  }
  CIPHERSUITES_SELECT = {
      "AES-128-CBC" => "AES-128-CBC",
      "BF-CBC" => "BF-CBC",
      "CAST5-CBC" => "CAST5-CBC",
      "none" => "none"
  }

  MTU_DISCOVERIES_SELECT = {
      "" => "",
      "No" => "no",
      "Maybe" => "maybe",
      "Yes" => "yes"
  }


  CIPHERSUITES = %w(AES-128-CBC BF-CBC CAST5-CBC none)
  PROTOCOLS = %w(udp tcp)
  MTU_DISCOVERIES = ["no", "maybe", "yes", " "]

  attr_readonly :wisp_id

  acts_as_authorization_object :subject_class_name => 'Operator'

  validates_presence_of :name, :port, :cipher, :protocol
  # Avoids 2 servers on the same port
  validates_uniqueness_of :port, :scope => [:ip, :protocol, :server_id]
  validates_uniqueness_of :name, :scope => :wisp_id
  validates_format_of :name, :with => /\A[a-z][\s\w\d_\.\-]*\Z/i
  validates_length_of :name, :maximum => 32
  validates_inclusion_of :protocol, :in => L2vpnServer::PROTOCOLS
  validates_inclusion_of :cipher, :in => L2vpnServer::CIPHERSUITES
  validates_numericality_of :port,
                            :only_integer => true,
                            :greater_than => 1024,
                            :less_than_or_equal_to => 65535
  validates_numericality_of :mtu,
                            :only_integer => true,
                            :greater_than => 575,
                            :less_than_or_equal_to => 1500,
                            :allow_nil => :true
  validates_inclusion_of :mtu_disc, :in => L2vpnServer::MTU_DISCOVERIES, :allow_blank => true
  validates_presence_of :server_id
  validates_presence_of :wisp_id
  validates_presence_of :ip # may be an hostname
  validates_format_of :ip, :with => /\A[\w\d\.\-]+\Z/i
  validates_length_of :name, :maximum => 128

  has_one :tap, :as => :l2vpn, :dependent => :destroy
  has_one :x509_certificate, :as => :certifiable, :dependent => :destroy

  has_many :l2vpn_templates, :dependent => :destroy
  has_many :l2vpn_clients, :dependent => :destroy

  belongs_to :wisp
  belongs_to :server

  somehow_has :many => :access_points, :through => :l2vpn_templates

  before_save :outdate_configuration_if_required
  before_destroy :outdate_configuration_if_required

  after_create do |record|
    record.wisp.ca.create_openvpn_server_certificate(record, {:validity_time => 2.years})
  end

  def generate_configuration
    @ca_name = Ca.find(self.x509_certificate.ca_id).cn.gsub(" ", "_")
    @openvpn_conf = ActionView::Base.new(Rails::Configuration.new.view_path).render(
        :partial => "l2vpn_servers/openvpn_conf", :locals => {:l2vpn_server => self, :ca_name => @ca_name}
    )
    @tarname = "server-openvpn-#{self.server.id}-#{self.id}.tar.gz"
    entries_date = Time.now

    Archive.write_open_filename(
        SERVERS_CONFIGURATION_PATH.join("#{@tarname}").to_s,
        Archive::COMPRESSION_GZIP, Archive::FORMAT_TAR
    ) do |tar|
      tar.new_entry do |entry|
        entry.pathname = "openvpn/openvpn.conf"
        entry.mode = 33056
        entry.mtime = entry.ctime = entry.atime = entries_date
        entry.size = @openvpn_conf.length
        tar.write_header(entry)
        tar.write_data(@openvpn_conf)
      end
      tar.new_entry do |entry|
        entry.pathname = "openvpn/#{@ca_name}-ca-crt.pem"
        entry.mode = 33056
        entry.mtime = entry.ctime = entry.atime = entries_date
        entry.size = self.wisp.ca.x509_certificate.certificate.length
        tar.write_header(entry)
        tar.write_data(self.wisp.ca.x509_certificate.certificate)
      end
      tar.new_entry do |entry|
        entry.pathname = "openvpn/#{@ca_name}-server-crt.pem"
        entry.mode = 33024
        entry.mtime = entry.ctime = entry.atime = entries_date
        entry.size = self.x509_certificate.certificate.length
        tar.write_header(entry)
        tar.write_data(self.x509_certificate.certificate)
      end
      tar.new_entry do |entry|
        entry.pathname = "openvpn/#{@ca_name}-server-key.pem"
        entry.mode = 33024
        entry.mtime = entry.ctime = entry.atime = entries_date
        entry.size = self.x509_certificate.key.length
        tar.write_header(entry)
        tar.write_data(self.x509_certificate.key)
      end
      tar.new_entry do |entry|
        entry.pathname = "openvpn/#{@ca_name}-dh1024.pem"
        entry.mode = 33024
        entry.mtime = entry.ctime = entry.atime = entries_date
        entry.size = self.dh.length
        tar.write_header(entry)
        tar.write_data(self.dh)
      end
      tar.new_entry do |entry|
        entry.pathname = "openvpn/#{@ca_name}-tls-data-key.pem"
        entry.mode = 33024
        entry.mtime = entry.ctime = entry.atime = entries_date
        entry.size = self.tls_auth.length
        tar.write_header(entry)
        tar.write_data(self.tls_auth)
      end
    end

  end

  def initialize(params = nil)
    super
    self.protocol = DEFAULT_PROTOCOL unless self.protocol
    self.cipher = DEFAULT_CIPHER unless self.cipher
  end

  # Certifiable interface
  def identifier
    "l2vpn_server_#{self.server.id}_#{self.id}"
  end

  def machine
    self.server
  end

  private

  OUTDATING_ATTRIBUTES = [:ip, :port, :protocol, :cipher, :mtu, :mtu_disc, :server_id, :wisp_id]

  def outdate_configuration_if_required
    if destroyed? or OUTDATING_ATTRIBUTES.any? { |attribute| send "#{attribute}_changed?" }
      if related_access_points
        related_access_points.each { |access_point| access_point.outdate_configuration! }
      end
    end
  end

end
