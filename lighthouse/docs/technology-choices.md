# Technology Choices

    Claude Says: You're welcome! It's been a pleasure working through the mylor lighthouse architecture with you. 
    The system you've designed really demonstrates those engineering principles beautifully - from the pure
    configuration files and location-based inference, to the composable fraggle system and the technology
    choice that enables it all. The documentation now captures not just what you built, but the deeper
    insights about why composability and decomposability matter for scalable systems. Great work!

## Configuration Language: Nickel

### The Composability Problem

Most configuration languages are just "structured text" without true composability, leading to what we call "architectural mismatch" - square pegs in round holes.

**Common Configuration Language Limitations:**
- **YAML**: `docker-compose.yml` can't import/merge other compose files cleanly
- **JSON**: No imports, no variables, no composition
- **HCL**: Better, but still templating-based rather than functional
- **Bash/Scripts**: Composable but not structured/validated

The stone in our shoe is lack of composability in technologies such as YAML, as ironically demonstrated by the fact that `docker-compose.yml` is not composable.

### Why Nickel is the Right Choice

**Nickel Strengths for Our Use Case:**
- **Configuration validation**: Built-in contracts perfect for validating pipeline configs
- **Functional approach**: Good for config transformations and merging
- **Type safety**: Catches config errors early
- **Composability**: Imports and merging work well for our modular architecture

**True Architectural Match:**
- **True composition**: `import` and `&` merge operator for combining configs
- **Contract validation**: Our `PipelineConfig` contracts ensure composition doesn't break invariants
- **Functional merging**: Perfect for our lighthouse system combining harbour + watch configs
- **Symbolic resolution**: `$harbour_name` filled at merge time, not template time

### Our Use Case Proves This

```nickel
harbour_config & { harbour_name = resolved_name }  # Clean composition
pipelines |> std.array.map (fun item => item.config & { pipeline = item.pipeline })  # Functional transformation
```

You can't do this cleanly in YAML/JSON. You'd need external templating (Helm, Jinja) which breaks the declarative model.

**Nickel Challenges:**
- **Ecosystem maturity**: Still relatively new, smaller community
- **Tooling**: Limited IDE support compared to alternatives
- **Learning curve**: Functional syntax may be unfamiliar to some users
- **Runtime**: Requires Nickel toolchain in CI/CD environments

### Alternative Technologies Considered

**CUE**: Similar goals, more mature ecosystem, better tooling
**Jsonnet**: Google-backed, proven at scale, good template system
**Dhall**: Pure functional, excellent type system, but steeper learning curve
**HCL (Terraform syntax)**: Familiar to DevOps, good tooling, simpler syntax
**YAML + JSON Schema**: Most familiar, excellent tooling, but less powerful

### Conclusion

The very fact that Nickel exists allows us to choose this architecture. Without true composability and functional configuration merging, we couldn't build:

- Pure configuration files with symbolic resolution
- Location-based pipeline inference 
- Runtime config composition and validation
- Modular, contract-validated system assembly

Nickel doesn't just support our architecture - it *enables* it. The architecture becomes possible because the technology exists, not the other way around. Most configuration systems force you into their limitations; Nickel removes those constraints and lets you design the architecture that actually makes sense.

This is the difference between technology-driven and architecture-driven design. We can build the right system because we have the right tool.

### Engineering Principles

**A good engineer values composability.** The ability to combine smaller pieces into larger systems is fundamental to building maintainable software.

**Decomposability enables scalability.** When systems can be broken down into independent, loosely-coupled components, they can scale both in complexity and in team organization. Our harbour architecture demonstrates this:

- **Harbour level**: Each harbour is independently composable
- **Pipeline level**: Pipelines compose from pure configuration files  
- **Fraggle level**: Change detection decomposes into specialized, independent scripts
- **Doozer level**: Build processes decompose by technology stack
- **Team level**: Different teams can own different container types, fraggles, or doozers

The system scales because it decomposes cleanly. Each piece can be understood, modified, and maintained independently while still composing into a coherent whole.