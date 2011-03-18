require "ipaddr"

class Bridge < ActiveRecord::Base
  acts_as_authorization_object :subject_class_name => 'Operator'

  ADDRESSING_MODES = %w( static dynamic none )

  validates_inclusion_of :addressing_mode, :in => BridgeTemplate::ADDRESSING_MODES,
                         :unless => Proc.new { |b| b.belongs_to_access_point? and b.addressing_mode.nil? }
  validates_uniqueness_of :ip, :scope => [ :machine_id, :machine_type ],
                          :allow_nil => :true,
                          :if => Proc.new { |b| b.addressing_mode == 'static' }
  validates_uniqueness_of :name, :scope => [ :machine_id, :machine_type ],
                          :unless => Proc.new { |b| b.belongs_to_access_point? and b.name.nil? }
  validates_format_of :name, :with => /\A[a-z][a-z0-9]*\Z/i,
                      :unless => Proc.new { |b| b.belongs_to_access_point? and b.name.nil? }
  validates_length_of :name, :maximum => 8,
                      :unless => Proc.new { |b| b.belongs_to_access_point? and b.name.nil? }

  has_many :ethernets, :dependent => :nullify
  has_many :taps, :dependent => :nullify
  has_many :vaps, :dependent => :nullify
  has_many :vlans, :dependent => :nullify

  belongs_to :machine, :polymorphic => true

  # Instance template
  belongs_to :bridge_template
  belongs_to :template, :class_name => 'BridgeTemplate', :foreign_key => :bridge_template_id

  before_save do |record|
    record.machine.configuration_outdated! if !record.new_record? and record.belongs_to_access_point?
  end

  def belongs_to_access_point?
    self.machine.class == AccessPoint
  end

  def before_create()
    unless self.bridge_template.nil?
      # Auto-generate ip address if needed
      if (self.bridge_template.addressing_mode == 'static')
        ip_bridges_in_template = self.bridge_template.bridges.find(:all, :lock => true).collect { |br|
          IPAddr.new(br.ip).to_i
        }
        if ip_bridges_in_template.length > 0
          ip_bridges_in_template.sort!

          i=0
          if IPAddr.new(ip_bridges_in_template[0], Socket::AF_INET).to_s == self.bridge_template.ip_range_begin
            while (i < (ip_bridges_in_template.length - 1)) and
                ((ip_bridges_in_template[i] + 1) == ip_bridges_in_template[i+1]) do
              i+=1
            end
            if ip_bridges_in_template[i] + 1 > IPAddr.new(self.bridge_template.ip_range_end, Socket::AF_INET).to_i
              raise "Range exausted" # TO DO: Error reporting
            end
            self.ip = IPAddr.new(ip_bridges_in_template[i] + 1, Socket::AF_INET).to_s
          else
            self.ip = self.bridge_template.ip_range_begin
          end
        else
          self.ip = self.bridge_template.ip_range_begin
        end
      end
    end
  end

  # Template related functions

  def link_to_template(t)
    self.template = t

    # We have to update every interface instances to create the appropriate bridging
    # configuration

    # Search for interfaces with a template linked with a bridge_template that match this
    # bridge template (WoW)
    self.machine.ethernets.each do |i|
      if !i.template.instances.nil? and (i.template.bridge_template == self.template)
        # Link interface to this bridge because its template is linked to this bridge
        # template
        i.bridge = self
        unless i.save!
          raise ActiveRecord::Rollback
        end
      end
    end

    # Search for interfaces with a template linked with a bridge_template that match this 
    # bridge template (WoW)
    self.machine.taps.each do |i|
      if !i.template.instances.nil? and (i.template.bridge_template == self.template)
        # Link interface to this bridge because its template is linked to this bridge
        # template
        i.bridge = self
        unless i.save!
          raise ActiveRecord::Rollback
        end
      end
    end

    # Search for interfaces with a template linked with a bridge_template that match this 
    # bridge template (WoW)
    self.machine.vaps.each do |i|
      if !i.template.instances.nil? and (i.template.bridge_template == self.template)
        # Link interface to this bridge because its template is linked to this bridge
        # template
        i.bridge = self
        unless i.save!
          raise ActiveRecord::Rollback
        end
      end
    end

    # Search for interfaces with a template linked with a bridge_template that match this 
    # bridge template (WoW)
    self.machine.vlans.each do |i|
      if !i.template.instances.nil? and (i.template.bridge_template == self.template)
        # Link interface to this bridge because its template is linked to this bridge
        # template
        i.bridge = self
        unless i.save!
          raise ActiveRecord::Rollback
        end
      end
    end

  end

  def personalized?
    template.nil? ? true : [:name, :netmask, :gateway, :dns, :addressing_mode].any?{|attr| !read_attribute(attr).blank? }
  end

  # Accessor methods (read)
  def name
    if (read_attribute(:name).blank? or read_attribute(:name).nil?) and !template.nil?
      return template.name
    end

    read_attribute(:name)
  end

  def netmask
    if (read_attribute(:netmask).blank? or read_attribute(:netmask).nil?) and !template.nil?
      return template.netmask
    end

    read_attribute(:netmask)
  end

  def gateway
    if (read_attribute(:gateway).blank? or read_attribute(:gateway).nil?) and !template.nil?
      return template.gateway
    end

    read_attribute(:gateway)
  end

  def dns
    if (read_attribute(:dns).blank? or read_attribute(:dns).nil?) and !template.nil?
      return template.dns
    end

    read_attribute(:dns)
  end

  def addressing_mode
    if (read_attribute(:addressing_mode).blank? or read_attribute(:addressing_mode).nil?) and !template.nil?
      return template.addressing_mode
    end

    read_attribute(:addressing_mode)
  end

  def bridgeables
    (ethernets + taps  + vaps + vlans).flatten
  end

end
