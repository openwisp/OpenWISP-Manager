class L2tc < ActiveRecord::Base
  acts_as_authorization_object :subject_class_name => 'Operator'

  belongs_to :shapeable, :polymorphic => true
  belongs_to :access_point

  belongs_to :l2tc_template

  after_save :outdate_configuration_if_required

  def validate
    sum = 0
    self.shapeable.subinterfaces.each do |s|
      sum += s.output_band_percent unless s.output_band_percent.nil?
    end
    if sum > 100
      errors.add_to_base(:Subinterface_percentage_sum_greater_than_100_perc)
      return false
    end

    if sum > 0 and (self.shapeable.output_band.blank? or self.shapeable.output_band.nil?)
      errors.add_to_base(:Interface_must_be_specified)
      return false
    end

    true
  end

  def link_to_template(template)
    self.l2tc_template = template
  end

  def unknown_output_band
    if self.shapeable.output_band.nil?
      nil
    else
      sum = 0
      self.shapeable.subinterfaces.each do |s|
        sum += s.output_band unless s.output_band.nil?
      end
      if self.shapeable.output_band - sum > 0
        self.shapeable.output_band - sum
      else
        1
      end
    end
  end

  def optimal_r2q
    if !self.shapeable.output_band.nil?
      max = self.shapeable.output_band
      min = max
      self.shapeable.subinterfaces.each { |s|
        unless s.output_band.nil?
          min = s.output_band if min > s.output_band
        end
      }
      if self.unknown_output_band > 0
        max = self.unknown_output_band if self.unknown_output_band > max
        min = self.unknown_output_band if self.unknown_output_band < min
      end
      r2q_max = (min*1024/8) / 1500.0
      r2q_min = (max*1024/8) / 60000.0
      r2q = ((r2q_max + r2q_min) / 2).ceil
      r2q
    else
      nil
    end
  end

  private

  def outdate_configuration_if_required
    access_point.outdate_configuration! if access_point && (new_record? || changed? || destroyed?)
  end
end
