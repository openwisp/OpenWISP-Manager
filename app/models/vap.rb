class Vap < ActiveRecord::Base
  acts_as_authorization_object :subject_class_name => 'Operator'

  NAME_PREFIX = "vap"

  ENC_TYPES = %w(none wep psk psk2 wpa wpa2 pskmixed wpamixed)
  ENC_TYPES_SELECT = {
      'none'            => 'none',
      'WEP'             => 'wep',
      'WPA psk'         => 'psk',
      'WPA2 psk'        => 'psk2',
      'WPA 802.1x'      => 'wpa',
      'WPA2 802.1x'     => 'wpa2',
      'WPA/WPA2 psk'    => 'pskmixed',
      'WPA/WPA2 802.1x' => 'wpamixed'
  }
  ENC_TYPES_FSELECT = {
      'none'        => 'none',
      'wep'         => 'WEP',
      'psk'         => 'WPA psk',
      'psk2'        => 'WPA2 psk',
      'wpa'         => 'WPA 802.1x',
      'wpa2'        => 'WPA2 802.1x',
      'pskmixed'    => 'WPA/WPA2 psk',
      'wpamixed'    => 'WPA/WPA2 802.1x'
  }
  ENC_TYPES_WKEY = %w(wep psk psk2 wpa wpa2 pskmixed wpamixed)
  ENC_TYPES_WRADIUS = %w(wpa wpa2 wpamixed)

  VISIBILITIES = %w(hidden broadcasted)
  VISIBILITIES_SELECT = {
      'Hidden'      => 'hidden',
      'Broadcasted' => 'broadcasted'
  }
  VISIBILITIES_FSELECT = {
      'hidden'      => 'Hidden',
      'broadcasted' => 'Broadcasted'
  }

  belongs_to :bridge
  belongs_to :radio

  # Instance template
  belongs_to :vap_template
  belongs_to :template, :class_name => 'VapTemplate', :foreign_key => :vap_template_id

  def key_needed?
    VapTemplate::ENC_TYPES_WKEY.include?(encryption)
  end

  def radius_needed?
    VapTemplate::ENC_TYPES_WRADIUS.include?(encryption)
  end

  def link_to_template(t)
    self.template = t
  end

  def do_bridge!(b)
    self.bridge = b
    self.save!
  end

  def do_unbridge!
    self.bridge = nil
    self.save!
  end

  # Accessor methods (read)
  def name
    if self.template.nil?
      "r#{self.radio.id}v#{self.id}"
    else
      "r#{self.radio.template.id}v#{self.template.id}"
    end
  end

  def friendly_name
    "essid '#{self.essid}' - radio: #{self.radio.name}"
  end

  def essid
    if (read_attribute(:essid).blank? or read_attribute(:essid).nil?) and !template.nil?
      return template.essid
    end

    read_attribute(:essid)
  end

  def visibility
    if (read_attribute(:visibility).blank? or read_attribute(:visibility).nil?) and !template.nil?
      return template.visibility
    end

    read_attribute(:visibility)
  end

  def encryption
    if (read_attribute(:encryption).blank? or read_attribute(:encryption).nil?) and !template.nil?
      return template.encryption
    end

    read_attribute(:encryption)
  end

  def key
    if (read_attribute(:key).blank? or read_attribute(:key).nil?) and !template.nil?
      return template.key
    end

    read_attribute(:key)
  end

  def radius_auth_server
    if (read_attribute(:radius_auth_server).blank? or
        read_attribute(:radius_auth_server).nil?) and !template.nil?
      return template.radius_auth_server
    end

    read_attribute(:radius_auth_server)
  end

  def radius_auth_server_port
    if (read_attribute(:radius_auth_server_port).blank? or read_attribute(:radius_auth_server_port).nil?) and !template.nil?
      return template.radius_auth_server_port
    end

    read_attribute(:radius_auth_server_port)
  end

  def radius_acct_server
    if (read_attribute(:radius_acct_server).blank? or read_attribute(:radius_acct_server).nil?) and !template.nil?
      return template.radius_acct_server
    end

    read_attribute(:radius_acct_server)
  end

  def radius_acct_server_port
    if (read_attribute(:radius_acct_server_port).blank? or read_attribute(:radius_acct_server_port).nil?) and !template.nil?
      return template.radius_acct_server_port
    end

    read_attribute(:radius_acct_server_port)
  end

  def output_band_percent
    if (read_attribute(:output_band_percent).blank? or read_attribute(:output_band_percent).nil?) and !template.nil?
      return template.output_band_percent
    end

    read_attribute(:output_band_percent)
  end

  def output_band
    if self.radio.output_band.nil? or self.output_band_percent.nil?
      nil
    else
      self.radio.output_band * self.output_band_percent / 100
    end
  end

  def tc_protocol
    'ip'
  end

end
