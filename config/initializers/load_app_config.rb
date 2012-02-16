app_config = YAML.load_file(Rails.root.join('config', 'app_config.yml'))
if app_config.nil? || app_config[Rails.env].nil?
  # do the following so we don't have ugly 'if..else's in our code:
  APP_CONFIG = Hash.new
  APP_CONFIG[:version] = 'unknown'
  APP_CONFIG[:show_versions_and_limits] = false
  APP_CONFIG[:pdf_max_records] = 1000 # sensible default if your server's memory is 2GB, adjust accordingly
else
  APP_CONFIG = app_config[Rails.env].symbolize_keys
  if APP_CONFIG[:pdf_max_records].blank?
    APP_CONFIG[:pdf_max_records] = 1000 # sensible default if your server's memory is 2GB, adjust accordingly
  end
end
