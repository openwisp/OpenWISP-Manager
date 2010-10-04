class ConsolidatorWorker < BackgrounDRb::MetaWorker

  set_worker_name :consolidator_worker

  def create(args = nil)
    # this method is called, when worker is loaded for the first time
  end  
  
  def daily_consolidate
		AccessPoint.all.each do |ap| 
          active_hours = HourlyMonitoringAccessPoint.find_all_by_access_point_id_and_date(ap.id, Date.today-1).length
          active_hours = (active_hours*100)/24
          WeeklyMonitoringAccessPoint.new( :percentage => active_hours, :access_point_id => ap.id, :date => Date.today-1 ).save!
    end
  end

end
