# Example lighthouse system merge logic
let types = import "./types.ncl" in
let utils = import "./utils.ncl" in

# Read pure config files
let harbour_config = import "../config/harbour.ncl" in
let lighthouse_config = import "./lighthouse-watch.ncl" in

# Environment resolution
let github_repo = std.env.var "GITHUB_REPOSITORY" | default = "unknown/example" in
let resolved_harbour_name = utils.basename github_repo in

# Merge and resolve symbolic values
let resolved_harbour = harbour_config & {
  harbour_name = resolved_harbour_name,
} in

# Dynamic discovery with path inference
let discover_watch_files = fun container_type =>
  # In real implementation, this would scan filesystem
  # Pattern: ../{container_type}/**/**/watch.ncl
  if container_type == "keg" then [
    {
      file_path = "keg/keith/test/0.1/watch.ncl",
      pipeline = "keg/keith/test/0.1",  # Derived from file path
      config = import "../keg/keith/test/0.1/watch.ncl",
    }
    # Would discover and derive paths for all files:
    # { file_path = "keg/anthony/devcontainer/0.1/config/watch.ncl", 
    #   pipeline = "keg/anthony/devcontainer/0.1", ... }
  ]
  else [] in

let discovered_pipelines = 
  resolved_harbour.container_types
  |> std.array.map (fun ct => std.enum.to_string ct)
  |> std.array.flat_map discover_watch_files in

let pipelines = 
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
  pipelines = pipelines,
  
  # System metadata
  resolved_at = std.time.now,
  source_repo = github_repo,
  
  # Fraggle system metadata
  fraggle_config = {
    state_cache_key = "fraggle-state-" ++ std.hash.md5 (std.serialize.json pipelines),
    supported_fraggles = ["github", "docker", "cron", "webhook"],
    matrix_sort_field = "priority",
  },
} | types.HarbourSystem  # Validation applied to complete merged result