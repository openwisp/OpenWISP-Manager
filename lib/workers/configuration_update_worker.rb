class ConfigurationUpdateWorker < BackgrounDRb::MetaWorker
  set_worker_name :configuration_update_worker

  def create(args = nil)
    # this method is called, when worker is loaded for the first time
  end

  # Update  access points configurations
  def outdated_access_points_update(options={})
    options[:access_point_ids] || raise("BUG: missing :access_point_ids arg")

    options[:access_point_ids].each do |ap_id|
      ap = AccessPoint.find(ap_id)
      ap.generate_configuration
      ap.generate_configuration_md5
    end
    true
  end

end
