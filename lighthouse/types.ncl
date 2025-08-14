let harbour = import "../config/harbour.ncl" in

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
    file_filter | optional (Array String),
    filter_mode | [| 'any, 'all |] | default = 'any,
  },

  PipelineConfig = {
    pipeline | PipelinePathContract,
    description | optional String,
    github_resources | Array GitHubResource,
    triggers | Array String,
    check_interval | Number | default = harbour.default_check_interval,
  },
  
  # Export contracts for reuse
  ContainerTypeContract = ContainerTypeContract,
  PipelinePathContract = PipelinePathContract,
  Harbour = harbour,
}