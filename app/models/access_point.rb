class AccessPoint < ActiveRecord::Base
  acts_as_authorization_object :subject_class_name => 'Operator'

  acts_as_mappable :default_units => :kms,
                   :default_formula => :sphere,
                   :distance_field_name => :distance,
                   :lat_column_name => :lat,
                   :lng_column_name => :lon

  acts_as_markable_on_change :watch_for => [
      :name, :mac_address, :access_point_template
  ]

  validates_presence_of :name, :mac_address, :address, :city, :zip
  validates_presence_of :lat, :lon, :message => :not_valid_f

  validates_uniqueness_of :name, :mac_address

  validates_numericality_of :lat, :allow_nil => true
  validates_numericality_of :lon, :allow_nil => true

  validates_format_of :name, :with => /\A[\w\d_]+\Z/
  validates_length_of :name, :maximum => 8

  validates_format_of :last_configuration_retrieve_ip, :with => /\A[0-9a-f:\.]+\Z/i, :allow_nil => true
  validates_format_of :mac_address, :with => /\A([0-9a-fA-F][0-9a-fA-F]:){5}[0-9a-fA-F][0-9a-fA-F]\Z/
  validates_format_of :address, :with => /\A[\s\w\d\.',]+\Z/
  validates_length_of :address, :maximum => 128
  validates_format_of :city, :with => /\A[\s\w\d\.']+\Z/
  validates_length_of :city, :maximum => 32
  validates_format_of :zip, :with => /\A[\s\w\d]+\Z/
  validates_length_of :zip, :maximum => 32


  belongs_to :wisp
  has_and_belongs_to_many :access_point_groups

  has_many :radios, :dependent => :destroy
  has_many :ethernets, :as => :machine, :dependent => :destroy
  has_many :bridges, :as => :machine, :dependent => :destroy
  has_many :l2vpn_clients, :dependent => :destroy
  has_many :l2tcs, :dependent => :destroy
  has_many :custom_scripts, :dependent => :destroy

  has_many :taps, :through => :l2vpn_clients
  has_many :vaps, :through => :radios

  # Instance template
  belongs_to :access_point_template
  belongs_to :template, :class_name => 'AccessPointTemplate', :foreign_key => :access_point_template_id


  def generate_configuration

    @uci_system       = ActionView::Base.new(Rails::Configuration.new.view_path).render(
        :partial => "access_points/uci_system", :locals => { :access_point => self}
    )
    @uci_network      = ActionView::Base.new(Rails::Configuration.new.view_path).render(
        :partial => "access_points/uci_network", :locals => { :access_point => self }
    )
    @uci_wireless     = ActionView::Base.new(Rails::Configuration.new.view_path).render(
        :partial => "access_points/uci_wireless", :locals => { :access_point => self }
    )
    @uci_openvpn      = ActionView::Base.new(Rails::Configuration.new.view_path).render(
        :partial => "access_points/uci_openvpn", :locals => { :access_point => self }
    )
    @l2tc_script      = ActionView::Base.new(Rails::Configuration.new.view_path).render(
        :partial => "access_points/l2tc_script", :locals => { :access_point => self }
    )
    @install_script   = ActionView::Base.new(Rails::Configuration.new.view_path).render(
        :partial => "access_points/install_script", :locals => { :access_point => self }
    )
    @uninstall_script = ActionView::Base.new(Rails::Configuration.new.view_path).render(
        :partial => "access_points/uninstall_script", :locals => { :access_point => self }
    )
    @vpn_scripts = {}

    @tarname = "ap-#{self.wisp.id}-#{self.id}.tar.gz"
    entries_date = Time.now

    Archive.write_open_filename(
        ACCESS_POINTS_CONFIGURATION_PATH.join("#{@tarname}").to_s,
        Archive::COMPRESSION_GZIP, Archive::FORMAT_TAR
    ) do |tar|
      tar.new_entry do |entry|
        entry.pathname = "uci/system.conf"
        entry.mode = 33056
        entry.mtime = entry.ctime = entry.atime = entries_date
        entry.size = @uci_system.length
        tar.write_header(entry)
        tar.write_data(@uci_system)
      end

      tar.new_entry do |entry|
        entry.pathname = "uci/network.conf"
        entry.mode = 33056
        entry.mtime = entry.ctime = entry.atime = entries_date
        entry.size = @uci_network.length
        tar.write_header(entry)
        tar.write_data(@uci_network)
      end
      tar.new_entry do |entry|
        entry.pathname = "uci/wireless.conf"
        entry.mode = 33056
        entry.mtime = entry.ctime = entry.atime = entries_date
        entry.size = @uci_wireless.length
        tar.write_header(entry)
        tar.write_data(@uci_wireless)
      end
      tar.new_entry do |entry|
        entry.pathname = "uci/openvpn.conf"
        entry.mode = 33056
        entry.mtime = entry.ctime = entry.atime = entries_date
        entry.size = @uci_openvpn.length
        tar.write_header(entry)
        tar.write_data(@uci_openvpn)
      end
      tar.new_entry do |entry|
        entry.pathname = "openvpn/x509/#{self.wisp.ca.identifier}.pem"
        entry.mode = 33056
        entry.mtime = entry.ctime = entry.atime = entries_date
        entry.size = self.wisp.ca.x509_certificate.certificate.length
        tar.write_header(entry)
        tar.write_data(self.wisp.ca.x509_certificate.certificate)
      end
      self.l2vpn_clients.each do |l2vpn_client|
        if l2vpn_client.x509_certificate
          tar.new_entry do |entry|
            cert = l2vpn_client.x509_certificate.certificate << l2vpn_client.x509_certificate.key
            entry.mode = 33024
            entry.mtime = entry.ctime = entry.atime = entries_date
            entry.size = cert.length
            entry.pathname = "openvpn/x509/#{l2vpn_client.identifier}.pem"
            tar.write_header(entry)
            tar.write_data(cert)
          end
        end

        l2vpn_bridges = []
        l2vpn_client.tap.vlans.each do |vlan|
          l2vpn_bridges.push(vlan.bridge) if !vlan.bridge.nil? and !l2vpn_bridges.include?(vlan.bridge)
        end
        l2vpn_bridges.push(l2vpn_client.tap.bridge) if !l2vpn_client.tap.bridge.nil? and !l2vpn_bridges.include?(l2vpn_client.tap.bridge)

        l2vpn_vaps = []
        l2vpn_bridges.each do |b|
          b.bridgeables.each do |v|
            l2vpn_vaps.push(v) if v.class == Vap
          end
        end

        @vpn_scripts["vpn_#{l2vpn_client.identifier}_script.sh"] = ActionView::Base.new(Rails::Configuration.new.view_path).render( :partial => "access_points/vpn_script", :locals => { :l2vpn_bridges => l2vpn_bridges, :l2vpn_vaps => l2vpn_vaps } )

        tar.new_entry do |entry|
          entry.pathname = "openvpn/vpn_#{l2vpn_client.identifier}_script.sh"
          entry.mode = 33128
          entry.mtime = entry.ctime = entry.atime = entries_date
          entry.size = @vpn_scripts["vpn_#{l2vpn_client.identifier}_script.sh"].length
          tar.write_header(entry)
          tar.write_data(@vpn_scripts["vpn_#{l2vpn_client.identifier}_script.sh"])
        end
      end

      unless self.access_point_template.nil?
        self.access_point_template.custom_script_templates.each do |custom_script_template|
          tar.new_entry do |entry|
            entry.pathname = "cron_scripts/T_#{custom_script_template.name}"
            entry.mode = 33128
            entry.mtime = entry.ctime = entry.atime = entries_date
            entry.size = custom_script_template.body.length
            tar.write_header(entry)
            tar.write_data(custom_script_template.body)
          end
        end
      end

      self.custom_scripts.each do |custom_script|
        tar.new_entry do |entry|
          entry.pathname = "cron_scripts/#{custom_script.name}"
          entry.mode = 33128
          entry.mtime = entry.ctime = entry.atime = entries_date
          entry.size = custom_script.body.length
          tar.write_header(entry)
          tar.write_data(custom_script.body)
        end
      end

      tar.new_entry do |entry|
        entry.pathname = "install.sh"
        entry.mode = 33128
        entry.mtime = entry.ctime = entry.atime = entries_date
        entry.size = @install_script.length
        tar.write_header(entry)
        tar.write_data(@install_script)
      end
      tar.new_entry do |entry|
        entry.pathname = "uninstall.sh"
        entry.mode = 33128
        entry.mtime = entry.ctime = entry.atime = entries_date
        entry.size = @uninstall_script.length
        tar.write_header(entry)
        tar.write_data(@uninstall_script)
      end
      tar.new_entry do |entry|
        entry.pathname = "l2tc_script.sh"
        entry.mode = 33128
        entry.mtime = entry.ctime = entry.atime = entries_date
        entry.size = @l2tc_script.length
        tar.write_header(entry)
        tar.write_data(@l2tc_script)
      end
    end

  end

  def generate_configuration_md5
    configuration_file_name_and_path =
        ACCESS_POINTS_CONFIGURATION_PATH.join("ap-#{self.wisp.id}-#{self.id}.tar.gz")
    self.update_attributes(
        :configuration_md5 => OpenSSL::Digest::MD5.new(File.read(configuration_file_name_and_path)).to_s
    )
  end

  def link_to_template(t)
    return_value = false

    AccessPoint.transaction do
      self.template = t

      template.radio_templates.each do |rt|
        # This will also create (and link to appropriate templates) vaps
        nr = self.radios.build( { :access_point => self } )
        nr.link_to_template( rt )
        unless nr.save!
          raise ActiveRecord::Rollback
        end
      end

      template.l2vpn_templates.each do |vt|
        # This will also create (and link to appropriate templates) taps and theirs vlans
        nv = self.l2vpn_clients.build( { :access_point => self } )
        nv.link_to_template( vt )
        unless nv.save!
          raise ActiveRecord::Rollback
        end
      end

      template.ethernet_templates.each do |et|
        # This will also create (and link to appropriate templates) vlans
        ne = self.ethernets.build( { :machine => self } )
        ne.link_to_template( et )
        unless ne.save!
          raise ActiveRecord::Rollback
        end
      end

      template.bridge_templates.each do |bt|
        nb = self.bridges.build( { :machine => self } )
        nb.link_to_template( bt )
        unless nb.save!
          raise ActiveRecord::Rollback
        end
      end

      unless self.save!
        raise ActiveRecord::Rollback
      end

      return_value = true
    end

    return_value
  end

  def internal?
    self.internal == true
  end

  def interfaces
    # TODO: this should return an activerecord array
    self.ethernets + self.taps
  end

  def shapeables
    self.interfaces
  end

  def vlans
    # TODO: this should return an activerecord array
    (self.ethernets.map { | e | e.vlans } + self.taps.map { |t| t.vlans }).flatten
  end

  def is_outdated?
    if self.committed_at.blank?
      return false
    end

    if self.changing?
      return true
    end

    if self.changed_at > self.committed_at
      return true
    end

    false
  end

end
