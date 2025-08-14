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

# Dynamic discovery based on container_types
let discover_watch_files = fun container_type =>
  let base_path = "../" ++ container_type in
  # In real implementation, this would scan filesystem
  # For now, showing the concept with known files
  if container_type == "keg" then [
    import "../keg/keith/test/0.1/watch.ncl",
    # Would discover: ../keg/anthony/devcontainer/0.1/config/watch.ncl
    # Pattern: ../{container_type}/**/**/watch.ncl
  ]
  else [] in

let pipelines = 
  resolved_harbour.container_types
  |> std.array.map (fun ct => std.enum.to_string ct)
  |> std.array.flat_map discover_watch_files in

# Complete merged system configuration
{
  harbour = resolved_harbour,
  lighthouse = lighthouse_config,
  pipelines = pipelines,
  
  # System metadata
  resolved_at = std.time.now,
  source_repo = github_repo,
} | types.HarbourSystem  # Validation applied to complete merged result