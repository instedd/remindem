InsteddTelemetry.setup do |config|

  config.application = "remindem"

  # Load settings from yml
  config_path = File.join(Rails.root, 'config', 'telemetry.yml')
  custom_config = File.exists?(config_path) ? YAML.load_file(config_path).with_indifferent_access : nil

   if custom_config.present?
     config.server_url           = custom_config[:server_url]                   if custom_config.include? :server_url
     config.period_size          = custom_config[:period_size_hours].hours      if custom_config.include? :period_size_hours
     config.process_run_interval = custom_config[:run_interval_minutes].minutes if custom_config.include? :run_interval_minutes
   end

   config.add_collector Telemetry::AccountsCollector
   config.add_collector Telemetry::PhoneNumbersCollector
   config.add_collector Telemetry::RemindersCollector
   config.add_collector Telemetry::SubscribersCollector
end
