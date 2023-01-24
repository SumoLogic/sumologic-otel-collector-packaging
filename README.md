# sumologic-otel-collector-packaging

## Building

Packages can be built using the provided Dockerfile or locally.

### Required environment variables

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

When packaging a GitHub release with the tag `v0.69.0-sumo-0`:

```sh
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
  -e OTC_VERSION="$OTC_VERSION" \
  -e OTC_SUMO_VERSION="$OTC_SUMO_VERSION" \
  -e OTC_BUILD_NUMBER="$OTC_BUILD_NUMBER" \
  -v $(pwd):/src otelcol-sumo/cmake \
  cmake ../
  ```

#### Linux packages

1. Build all Linux packages:

  ```sh
  docker run -v $(pwd):/src otelcol-sumo/cmake make linux-packages
  ```

#### Single package

1. Find the `target_name` of the desired package from the list of make targets:

  ```sh
  docker run -v $(pwd):/src otelcol-sumosh -c 'make help | grep -e "^... package-"''
  ```

1. Build the package:

  ``` sh
  docker run -v $(pwd):/src otelcol-sumo/cmake make <target_name>
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

#### Linux packages

1. Build all Linux packages:

  ``` sh
  make linux-packages
  ```

#### DEB packages

1. Build all DEB packages:

  ``` sh
  make deb-packages
  ```

#### RPM packages

1. Build all RPM packages:

  ``` sh
  make rpm-packages
  ```

#### Single package

1. Find the `target_name` of the desired package from the packages directory.

1. Build the package:

  ``` sh
  make <target_name>
  ```

[cmake]: https://cmake.org/download/
