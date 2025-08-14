# Harbour Architecture

## Overview

A harbour is a self-describing, configuration-driven pipeline system. Each harbour defines what types of containers it supports (*kegs*, *flagons*, *sacks*) and manages pipeline configurations within those containers.

## Lighthouse Module

The lighthouse is an optional module within harbours that "scans the horizon" for external resources. Not all harbours need a lighthouse - it's only required when monitoring external dependencies like GitHub repositories, Docker registries, or other external triggers.

## Core Architecture

### Configuration-Driven Discovery

The harbour system uses `container_types` as the foundation for pipeline discovery:

```nickel
# config/harbour.ncl
{
  harbour_name = $harbour_name,  # Resolved from GITHUB_REPOSITORY
  container_types = [| 'keg, 'flagon, 'sack |],
  default_check_interval = 60,
}
```

The harbour system discovers pipelines in each container type directory:
- `keg/**/**/watch.ncl` - Container pipelines
- `flagon/**/**/watch.ncl` - Application pipelines  
- `sack/**/**/watch.ncl` - Data pipelines

When a lighthouse module is present, it monitors external resources and can trigger these pipelines.

### Pipeline Hierarchy

All pipelines follow a consistent 4-level hierarchy:
```
{container_type}/{user}/{project}/{version}/
```

Examples:
- `keg/keith/test/0.1/watch.ncl`
- `flagon/team-a/api/2.0/watch.ncl`
- `sack/data-eng/etl/1.5/watch.ncl`

## Pure Configuration Files

### harbour.ncl
- Defines container types supported by this harbour
- Uses symbolic names resolved at merge time
- No imports or dependencies

### watch.ncl Files
- Pure pipeline configuration data
- No imports or contract validation
- Located in 4-level hierarchy directories

### lighthouse-watch.ncl
- Lighthouse system configuration
- Check intervals, concurrency limits, timeouts
- Pure configuration data

## Harbour System

### Symbol Resolution
The harbour system resolves symbolic values at merge time:

```nickel
# Environment resolution
let github_repo = std.env.var "GITHUB_REPOSITORY"  # "keithy/mylor"
let resolved_harbour_name = utils.basename github_repo  # "mylor"

# Symbol resolution
let resolved_harbour = harbour_config & {
  harbour_name = resolved_harbour_name,  # $harbour_name → "mylor"
}
```

### Pipeline Discovery
The system uses container_types to drive discovery:

```nickel
let discover_watch_files = fun container_type =>
  # Scan ../{container_type}/**/**/watch.ncl
  # Import and collect all found configurations

let pipelines = 
  resolved_harbour.container_types
  |> std.array.map (fun ct => std.enum.to_string ct)
  |> std.array.flat_map discover_watch_files
```

### Complete System Merge
All configurations are merged into a validated system configuration:

```nickel
{
  harbour = resolved_harbour,
  lighthouse = lighthouse_config,  # Optional - only if lighthouse module present
  pipelines = pipelines,
  resolved_at = std.time.now,
  source_repo = github_repo,
} | types.HarbourSystem
```

### When to Use Lighthouse
- **External resource monitoring**: GitHub repos, Docker registries, APIs
- **Event-driven pipelines**: Trigger on commits, releases, webhooks  
- **Scheduled checks**: Periodic monitoring of external dependencies
- **Cross-repository coordination**: Multi-repo pipeline orchestration

Harbours without lighthouse modules run pipelines through other triggers (manual, CI/CD, cron, etc.).

## Benefits

### Self-Describing
- Harbour defines its own capabilities via container_types
- No external configuration needed for pipeline discovery
- Each harbour can support different container type combinations

### Scalable
- Add new container type → automatic pipeline discovery
- Remove container type → those pipelines ignored
- Each container type represents different workload patterns

### Clean Separation
- Pure data files (no dependencies or imports)
- Environment resolution at the right layer (lighthouse system)
- Validation applied to complete merged result
- No circular dependencies

### Environment-Aware
- Dynamic harbour naming from GITHUB_REPOSITORY
- Symbolic resolution allows template reuse
- Runtime environment drives configuration