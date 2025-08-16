let config = import "./config.ncl" in
{
  watch = config.resources.releases,
  order = 5,  # Lower numbers processed first
  # depends_on = [],  # Optional - no dependencies for this pipeline
}