class ConfigurationUpdateWorker < BackgrounDRb::MetaWorker
  set_worker_name :configuration_update_worker
  def create(args = nil)
    # this method is called, when worker is loaded for the first time
  end


  # Update the access points configuration of the template [access_point_template_id]
  def update_template_configuration ( access_point_template_id )
    access_point_template = AccessPointTemplate.find(access_point_template_id)
    access_point_template.access_points.each do |ap|
      ap.generate_configuration
      ap.generate_configuration_md5
    end
  end

  #Scan all the Access Points in each Wisps and Update them if its configuration is old
  def update_configuration
    AccessPoint.all.each do |ap| 
      if ap.is_outdated?
        ap.generate_configuration
        ap.generate_configuration_md5
      end
    end
  end

end
