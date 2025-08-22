# Sample harbour configuration for testing fraggle-cron.ncl.sh
{
  harbour = {
    harbour_name = "test-mylor",
    container_types = ["keg", "flagon", "sack"],
    default_check_interval = 60,
  },
  lighthouse = {
    check_interval = 30,
    max_concurrent_checks = 5,
    github_api_timeout = 30,
    notification_channels = ["slack", "email"],
  },
  pipelines = [
    {
      pipeline = "keg/test-app/nightly",
      description = "Test application nightly builds",
      triggers = ["nightly_build"],
      check_interval = 60,
      watch = {
        type = "github",
        repo = "testorg/test-app",
        branch = "main",
      },
      order = 1,
    },
    {
      pipeline = "sack/charm/crush/releases", 
      description = "Crush release builds",
      triggers = ["weekly_build", "release"],
      check_interval = 120,
      watch = {
        type = "github", 
        repo = "charmbracelet/crush",
        track = "releases",
      },
      order = 2,
    },
    {
      pipeline = "flagon/docs/daily",
      description = "Documentation builds",
      triggers = ["nightly_build"],
      check_interval = 240,
      watch = {
        type = "file",
        patterns = ["docs/**/*.md"],
      },
      order = 3,
    }
  ],
  resolved_at = "2024-08-15T01:00:00Z",
  source_repo = "testorg/test-mylor",
}