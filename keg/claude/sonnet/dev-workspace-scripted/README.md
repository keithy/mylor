# Script-Driven Developer Workspaces

This is a parallel implementation of the developer workspaces using the **script-driven Dockerfile approach** for comparison with the traditional Dockerfile approach.

## Key Differences

### Script-Driven Approach (`dev-workspace-scripted/`)
- **One standardized Dockerfile** for all workspaces
- **Workspace-specific build scripts** handle complexity
- **Parameterized builds** via ARG variables
- **Better error handling** with `ON_FAIL` parameter
- **Testable components** - build scripts can run independently

### Traditional Approach (`dev-workspace/`)  
- **Separate Dockerfile** for each workspace
- **Build logic embedded** in Dockerfile RUN statements
- **Limited flexibility** in build process
- **Hard to debug** build failures

## Structure Comparison

**Script-Driven:**
```
dev-workspace-scripted/
├── Dockerfile                    # ONE standardized template
├── base/
│   ├── build.sh                 # Smart build logic
│   └── mise/config.toml         # Tool configuration
├── web-dev/
│   ├── build.sh                 # Web-specific setup
│   └── mise/config.toml         # Web dev tools
└── ...
```

**Traditional:**
```
dev-workspace/
├── base/
│   ├── Dockerfile               # Monolithic build definition
│   └── mise/config.toml         # Tool configuration
├── web-dev/
│   ├── Dockerfile               # Repeated patterns
│   └── mise/config.toml         # Web dev tools  
└── ...
```

## Building Containers

### Script-Driven Build
```bash
# Build all workspaces using standardized Dockerfile
./build.sh

# Build specific workspace
./build.sh web-dev

# Debug mode (continue on build script failure)
ON_FAIL=continue ./build.sh base
```

### Parameterized Build
```bash
docker build \
  --build-arg BUILD_SCRIPT=build.sh \
  --build-arg ON_FAIL=continue \
  --build-arg USER_ID=1001 \
  -f Dockerfile \
  base/
```

## Advantages of Script-Driven Approach

1. **DRY Principle**: No duplicated Dockerfile patterns
2. **Maintainability**: Single source of truth for container structure
3. **Flexibility**: Full bash scripting power in build scripts
4. **Testability**: Build scripts can be tested independently
5. **Debugging**: Better error handling and debug modes
6. **Consistency**: All workspaces use identical container structure

## Testing Both Approaches

You can build equivalent containers using either approach:

```bash
# Traditional approach
cd ../dev-workspace
./build.sh base

# Script-driven approach  
cd ../dev-workspace-scripted
./build.sh base

# Compare the results
docker images | grep dev-workspace
```

Both produce functionally identical containers with the same tools and configurations, but the script-driven approach offers superior maintainability and flexibility.