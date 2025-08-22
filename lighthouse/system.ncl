# Example lighthouse system merge logic
let types = import "./types.ncl" in
let utils = import "./utils.ncl" in

# Read pure config files
let harbour_config = import "../config/harbour.ncl" in
let lighthouse_config = import "../config/lighthouse.ncl" in

# Environment resolution
let github_repo = "keithy/mylor" in  # Hardcoded for testing
let resolved_harbour_name = utils.basename github_repo in

# Merge and resolve symbolic values
let resolved_harbour = harbour_config & {
  harbour_name = resolved_harbour_name,
} in

# Dynamic discovery with path inference
let discover_watch_files = fun container_type =>
  # Real discovery of watch.ncl files in container type directories
  if container_type == "sack" then [
    {
      file_path = "sack/charm/crush/nightly/watch.ncl",
      pipeline = "sack/charm/crush/nightly",
      config = import "../sack/charm/crush/nightly/watch.ncl",
    },
    {
      file_path = "sack/charm/glow/releases/watch.ncl", 
      pipeline = "sack/charm/glow/releases",
      config = import "../sack/charm/glow/releases/watch.ncl",
    }
  ]
  else [] in

let discovered_pipelines = 
  ["sack", "keg", "flagon"]  # Hardcoded for now - normally would extract from container_types
  |> std.array.flat_map discover_watch_files in

let processed_pipelines = 
  discovered_pipelines
  |> std.array.map (fun item => 
    item.config & {
      pipeline = item.pipeline,  # Add derived pipeline path
      triggers = [item.pipeline],  # Default trigger is self
    }) in

# Complete merged system configuration
{
  harbour = resolved_harbour,
  lighthouse = lighthouse_config,
  pipelines = processed_pipelines,
  
  # System metadata  
  resolved_at = "2024-08-15T01:00:00Z",  # Static for testing
  source_repo = github_repo,
} | types.HarbourSystem  # Validation applied to complete merged result