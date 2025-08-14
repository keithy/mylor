{
  pipeline = "keg/keith/test/0.1",
  github_resources = [
    {
      type = 'github,
      owner = "keithy",
      repo = "mylor",
      branch = "main",
      track = 'commits,
      file_filter = ["keg/**/*.ncl", "lighthouse/**/*"],
    }
  ],
  triggers = [@pipeline],
}