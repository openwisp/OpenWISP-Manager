class CustomScriptTemplate < ActiveRecord::Base
  acts_as_authorization_object :subject_class_name => 'Operator'
  
  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :access_point_template_id
  
  validates_presence_of :body
  
  belongs_to :access_point_template, :touch => true
  
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
    
    unless self.cron_dayweek =~ /\A\*(\/[0-7])*\Z|\A[0-7]\-[0-7]\Z|\A[0-7](\,[0-7])*\Z|\Asun|mon|tue|wed|thu|fri|sat\Z/
      errors.add(:cron_dayweek, :cron_dayweek_wrong_format)
    end
    
  end
end