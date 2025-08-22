# fraggle-state.ncl - Type definitions for fraggle cron state management

{
  FraggleState = {
    last_nightly | String | optional,
    last_weekly | String | optional,
    last_monthly | String | optional,
    build_history | Array {
      date | String,
      trigger | [| 'nightly_build, 'weekly_build, 'monthly_build, 'manual |],
      pipelines | Array String,
      completed_at | String | optional,
    } | default = [],
  },
  
  MatrixEntry = {
    pipeline | String,
    trigger | [| 'nightly_build, 'weekly_build, 'monthly_build, 'manual |],
    priority | Number,
    schedule | {
      type | [| 'nightly, 'weekly, 'monthly, 'manual |],
      date | String,
      hour | Number,
    },
  },
  
  # Validation functions
  is_valid_date_key = fun date_str =>
    # Simple date validation - expects YYYY-MM-DD format
    let parts = std.string.split "-" date_str in
    let valid_length = std.array.length parts == 3 in
    let year_valid = std.string.length (std.array.at 0 parts) == 4 in
    let month_valid = std.string.length (std.array.at 1 parts) == 2 in
    let day_valid = std.string.length (std.array.at 2 parts) == 2 in
    valid_length && year_valid && month_valid && day_valid,
    
  # Helper to create initial empty state
  empty_state = {
    last_nightly = null,
    last_weekly = null,
    last_monthly = null,
    build_history = [],
  } | FraggleState,
}