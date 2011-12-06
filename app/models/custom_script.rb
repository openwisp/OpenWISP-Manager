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

class CustomScript < ActiveRecord::Base
  acts_as_authorization_object :subject_class_name => 'Operator'

  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :access_point_id
  validates_format_of :name, :with => /\A[\s\w\d_\.]+\Z/i
  validates_length_of :name, :maximum => 16

  validates_presence_of :body

  belongs_to :access_point

  after_save :outdate_configuration_if_required
  after_destroy :outdate_configuration_if_required

  def validate

    # 0-59 Numerical Range :: Examples:*, */1, */23 OR d1-d2 OR d1,d2,d3
    unless self.cron_minute =~ /\A\*(\/[1-5]?[0-9])*\Z|\A[1-5]?[0-9]\-[1-5]?[0-9]\Z|\A([1-5]?[0-9](\,[1-5]?[0-9])*)\Z/
      errors.add(:cron_minute, :cron_minute_wrong_format)
    end

    # 0-23 Numerical Range :: Examples:*, */1, */23 OR d1-d2 OR d1,d2,d3
    unless self.cron_hour =~ /\A\*(\/([0-9]{1}|1[0-9]|2[0-3]){1})*\Z|\A([0-9]{1}|1[0-9]|2[0-3]){1}\-([0-9]{1}|1[0-9]|2[0-3]){1}\Z|\A(([0-9]{1}|1[0-9]|2[0-3]){1}(\,([0-9]{1}|1[0-9]|2[0-3]){1})*)\Z/
      errors.add(:cron_hour, :cron_hour_wrong_format)
    end

    # 1-31 Numerical Range :: Examples:*, */1, */23 OR d1-d2 OR d1,d2,d3
    unless self.cron_day =~ /\A\*(\/([1-9]{1}|1[0-2]){1})*\Z|\A([1-9]{1}|1[0-2]){1}\-([1-9]{1}|1[0-2]){1}\Z|\A(([1-9]{1}|1[0-2]){1}(\,([1-9]{1}|1[0-2]){1})*)\Z|\Ajan|feb|mar|apr|may|jun|jul|ago|sep|oct|nov|dec\Z/
      errors.add(:cron_day, :cron_day_wrong_format)
    end

    # 1-12 Numerical Range :: Examples:*, */1, */23 OR d1-d2 OR d1,d2,d3 or jan,feb,mar,apr,may,jun,jul,ago,sep,oct,nov,dec
    unless self.cron_month =~ /\A\*(\/([1-9]{1}|1[0-2]){1})*\Z|\A([1-9]{1}|1[0-2]){1}\-([1-9]{1}|1[0-2]){1}\Z|\A(([1-9]{1}|1[0-2]){1}(\,([1-9]{1}|1[0-2]){1})*)\Z|\Ajan|feb|mar|apr|may|jun|jul|ago|sep|oct|nov|dec\Z/
      errors.add(:cron_month, :cron_month_wrong_format)
    end

    unless self.cron_weekday =~ /\A\*(\/[0-7])*\Z|\A[0-7]\-[0-7]\Z|\A[0-7](\,[0-7])*\Z|\Asun|mon|tue|wed|thu|fri|sat\Z/
      errors.add(:cron_weekday, :cron_weekday_wrong_format)
    end

  end

  private

  OUTDATING_ATTRIBUTES = [:body, :cron_minute, :cron_hour, :cron_day, :cron_month, :cron_weekday]

  def outdate_configuration_if_required
    if destroyed? or OUTDATING_ATTRIBUTES.any? { |attribute| send "#{attribute}_changed?" }
      access_point.outdate_configuration! if access_point
    end
  end

end
