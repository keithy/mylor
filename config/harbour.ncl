{
  harbour_name = "mylor",  # Temporary - normally resolved from $harbour_name
  container_types | not_exported = [| 'keg, 'flagon, 'sack |],
  # Other harbour-specific settings
  default_check_interval = 60,
  # etc.
}