# sumologic-otel-collector-packaging

## Building

Packages can be built using the provided Dockerfile or locally.

### Required environment variables

#### TARGET

Represents the target package to build. The value must be the name of a file in
the `targets` directory without the file extension.
(e.g. `otc_darwin_arm64_productbuild`)

Show the list of targets by running:

``` sh
find targets -name '*.cmake' -exec basename -s .cmake {} \;
```

#### OTC_VERSION

Represents the base version of otelcol-sumo. This value is used to fetch
the otelcol-sumo binary from GitHub Releases and as the version of the packages
produced by this project.

#### OTC_SUMO_VERSION

Represents the "sumo" version (e.g. the `X` in `A.B.C-sumo-X`) of otelcol-sumo.
It is used for fetching the otelcol-sumo binary from GitHub Releases.

#### OTC_BUILD_NUMBER

Represents the package release version (e.g. the `X` in `A.B.C-X`) used for
incremental changes to the packaging code. It should contain a unique, unsigned
integer that increments with each build to allow for upgrading from one package
to another. This is typically set to the job number of a CI job but can be set
to 0 when building packages for testing without upgrades.

#### Example

When packaging a GitHub release with the tag `v0.69.0-sumo-0` for macOS on an
arm64 processor:

```sh
export TARGET=otc_darwin_arm64_productbuild
export OTC_VERSION=0.69.0
export OTC_SUMO_VERSION=0
export OTC_BUILD_NUMBER=1234
```

---

### Using Docker

**NOTE:** This method only supports building deb & rpm packages.

1. First bake and load the image:

  ``` sh
  docker buildx bake --load
  ```

1. Build the Makefile:

  ```sh
  docker run \
  -e TARGET="$TARGET" \
  -e OTC_VERSION="$OTC_VERSION" \
  -e OTC_SUMO_VERSION="$OTC_SUMO_VERSION" \
  -e OTC_BUILD_NUMBER="$OTC_BUILD_NUMBER" \
  -v $(pwd):/src \
  -v $(pwd)/build:/build \
  otelcol-sumo/cmake \
  cmake /src
  ```

1. Build the package:

  ``` sh
  docker run -v $(pwd):/src otelcol-sumo/cmake make package
  ```

---

### Using local system

Building locally requires dependencies that will differ based on your platform
and the packages that you are trying to build. You will need [CMake][cmake] to
get started.

1. Build the Makefile:

``` sh
cd build && cmake ../
```

1. Build the package:

``` sh
make package
```

[cmake]: https://cmake.org/download/
