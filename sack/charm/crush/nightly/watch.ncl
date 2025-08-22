let config = import "./research.ncl" in
{
  watch = config.schedule.nightly,
  order = 10,  # Lower numbers processed first
  # depends_on = ["keg/vendor/some-dependency/stable"],  # Optional - example
}