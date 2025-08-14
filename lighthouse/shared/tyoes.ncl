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
    pipeline | String,
    description | optional String,
    github_resources | Array GitHubResource,
    triggers | Array String,
    check_interval | Number | default = 60,
  }
}