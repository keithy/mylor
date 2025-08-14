# lighthouse/utils.ncl
{
  basename = fun path =>
    let parts = std.string.split "/" path in
    std.array.last parts,
}