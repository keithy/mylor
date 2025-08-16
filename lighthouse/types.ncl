let harbour = import "../config/harbour.ncl" in
let utils = import "./utils.ncl" in

let ContainerTypeContract = 
  std.contract.from_predicate (fun container_type =>
    std.array.any (fun ct => container_type == std.enum.to_string ct) 
      (std.enum.variants harbour.container_types)
  ) in

let PipelinePathContract = 
  std.contract.from_predicate (fun path =>
    let parts = std.string.split "/" path in
    let valid_length = std.array.length parts == 4 in
    let first_part = parts |> std.array.at 0 in
    let valid_container = ContainerTypeContract first_part in
    let valid_parts = std.array.all (fun part => part != "" && part != null) parts in
    
    valid_length && valid_container && valid_parts
  ) in

{
  GitHubResource = {
    type | [| 'github |],
    owner | String,
    repo | String,
    branch | String | default = "main",
    track | [| 'commits, 'releases, 'tags |] | default = 'commits,
    file_filter | Array String | optional,
    filter_mode | [| 'any, 'all |] | default = 'any,
  },

  PipelineConfig = {
    pipeline | String,  # Simplified - normally would use PipelinePathContract
    description | String | optional,
    github_resources | Array GitHubResource | optional,
    triggers | Array String,
    check_interval | Number | default = harbour.default_check_interval,
    watch | Dyn,  # What the fraggle should watch (flexible type)  
    order | Number,  # Priority order (lower = first)
  },
  
  HarbourSystem = {
    harbour | {
      harbour_name | String,
      container_types | Dyn,  # Enum array - simplified for now
      default_check_interval | Number,
    },
    lighthouse | {
      check_interval | Number,
      max_concurrent_checks | Number,
      github_api_timeout | Number,
      notification_channels | Array String,
    },
    pipelines | Array PipelineConfig,
    resolved_at | String | optional,
    source_repo | String | optional,
  },

  # Note: Contract definitions available but not re-exported to avoid recursion
  Harbour = harbour,
  Utils = utils,
}