require "ipaddr"

class BridgeTemplate < ActiveRecord::Base
  acts_as_authorization_object :subject_class_name => 'Operator'

  ADDRESSING_MODES = %w( static dynamic none unspecified )

  validates_inclusion_of :addressing_mode, :in => BridgeTemplate::ADDRESSING_MODES

  validates_presence_of :ip_range_begin, :ip_range_end, :netmask, :if => :static_addressing?

  validates_uniqueness_of :name, :scope => :access_point_template_id
  validates_format_of :name, :with => /\A[a-z][a-z0-9]*\Z/i
  validates_length_of :name, :maximum => 8

  has_many :ethernet_templates, :dependent => :nullify
  has_many :tap_templates, :dependent => :nullify
  has_many :vap_templates, :dependent => :nullify
  has_many :vlan_templates, :dependent => :nullify

  belongs_to :access_point_template

  # Template instances
  has_many :bridges, :dependent => :destroy
  has_many :instances, :class_name => 'Bridge', :foreign_key => :bridge_template_id

  somehow_has :many => :access_points, :through => :access_point_template

  after_save :outdate_configuration_if_required
  after_destroy :outdate_configuration_if_required

  # Update linked template instances
  after_save { |record|
    if record.bridges.length == 0
      # We have a new bridge_template
      record.access_point_template.access_points.each do |h|
        # For each linked template instance, create a new bridge and associate it with
        # the corresponding access_point
        nb = h.bridges.build(:machine => h)
        nb.link_to_template(record)
        nb.save
      end
    end
  }

  def static_addressing?
    addressing_mode == 'static'
  end

  def validate
    unless self.bridges.nil? or self.bridges.length == 0
      if self.addressing_mode_changed? or self.ip_range_begin_changed? or
          self.ip_range_end_changed? or self.netmask_changed?
        errors.add_to_base(:cannot_update_addressing_on_linked_template)
      end
    end

    if self.addressing_mode == 'static'
      unless self.bridges.nil? or self.bridges.length == 0
        if self.ip_range_begin_changed? or self.ip_range_end_changed? or self.netmask_changed?
          errors.add_to_base(:cannot_update_addressing_on_linked_template)
        end
      end

      ip_r_begin = nil
      begin
        ip_r_begin = IPAddr.new(self.ip_range_begin) unless (self.ip_range_begin.nil? or self.ip_range_begin.blank?)
      rescue ArgumentError
        errors.add(:ip_range_begin, :invalid_ip_address)
      end

      ip_r_end = nil
      begin
        ip_r_end = IPAddr.new(self.ip_range_end) unless (self.ip_range_end.nil? or self.ip_range_end.blank?)
      rescue ArgumentError
        errors.add(:ip_range_end, :invalid_ip_address)
      end

      ip_r_begin_netmask = nil
      begin
        unless (self.netmask.nil? or self.netmask.blank?)
          ip_netmask = IPAddr.new(self.netmask) unless (self.netmask.nil? or self.netmask.blank?)
          # TODO: netmask semantic validation
          ip_r_begin_netmask = ip_r_begin.mask(self.netmask) unless ip_r_begin.nil?
        end
      rescue ArgumentError
        errors.add(:netmask, :invalid_ip_address)
      end

      ip_gateway = nil
      begin
        unless (self.gateway.nil? or self.gateway.blank?)
          ip_gateway = IPAddr.new(self.gateway) unless (self.gateway.nil? or self.gateway.blank?)
        end
      rescue ArgumentError
        errors.add(:gateway, :invalid_ip_address)
      end

      begin
        unless (self.dns.nil? or self.dns.blank?)
          ip_dns = IPAddr.new(self.dns) unless (self.dns.nil? or self.dns.blank?)
        end
      rescue ArgumentError
        errors.add(:dns, :invalid_ip_address)
      end

      if (!ip_r_begin.nil? and !ip_r_end.nil?)
        if (ip_r_begin.to_i > ip_r_end.to_i)
          errors.add(:ip_range_end, :must_be_greater_than_ip_range_start)
        else
          unless (ip_r_begin_netmask.nil? or ip_r_begin_netmask.include?(ip_r_end))
            errors.add(:ip_range_end, :must_be_in_network)
          end
        end
      elsif (!ip_r_begin.nil? and ip_r_end.nil?)
        errors.add(:ip_range_end, :needed_if_range_begin_present)
      elsif (ip_r_begin.nil? and !ip_r_end.nil?)
        errors.add(:ip_range_begin, :needed_if_range_end_present)
      else #(ip_r_begin.nil? and ip_r_end.nil?)
        errors.add(:ip_range_begin, :needed_for_static_addressent)
        errors.add(:ip_range_end, :needed_for_static_addressent)
      end

      if (!ip_gateway.nil? and !ip_r_begin_netmask.nil?)
        unless (ip_gateway.nil? or ip_r_begin_netmask.include?(ip_gateway))
          errors.add(:gateway, :must_be_in_network)
        end
      end
    end
  end

  def bridgeable_templates
    (ethernet_templates + tap_templates + vap_templates + vlan_templates).flatten
  end

  private

  OUTDATING_ATTRIBUTES = [:addressing_mode, :ip_range_begin, :ip_range_end, :name, :id]

  def outdate_configuration_if_required
    if destroyed? or OUTDATING_ATTRIBUTES.any? { |attribute| send "#{attribute}_changed?" }
      if related_access_points
        related_access_points.each { |access_point| access_point.outdate_configuration! }
      end
    end
  end

end
