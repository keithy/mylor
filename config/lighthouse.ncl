{
  check_interval = 60,
  max_concurrent_checks = 5,
  github_api_timeout = 30,
  notification_channels = [],
  
  # Schedule configuration
  schedules = {
    nightly = {
      hour = 2,             # UTC hour for nightly builds
      skip_weekends = true, # Skip Saturday (6) and Sunday (7)
      enabled = true
    },
    weekly = {
      hour = 3,     # UTC hour for weekly builds  
      day = 7,      # Day of week (1=Monday, 7=Sunday)
      enabled = true
    }
  }
}