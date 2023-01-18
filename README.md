# sumologic-otel-collector-packaging

## Building with Docker

**NOTE:** This method only supports building deb & rpm packages.

1. First bake and load the image:

  ``` sh
  docker buildx bake --load
  ```

1. Build the Makefile:

  ```sh
  docker run -v $(pwd):/src otelcol-sumo/cmake cmake ../
  ```

1. Build a package or packages.

### Building deb packages

```sh
docker run -v $(pwd):/src otelcol-sumo/cmake make deb-packages
```

### Building rpm packages

```sh
docker run -v $(pwd):/src otelcol-sumo/cmake make rpm-packages
```

### Building a single package

1. Find the `target_name` of the desired package from the packages directory.

1. Build the package:

  ``` sh
  docker run -v $(pwd):/src otelcol-sumo/cmake make <target_name>
  ```

## Building locally

1. Build the Makefile:

``` sh
cd build && cmake ../
```

1. Build a package or packages.

### Building all deb packages

``` sh
make deb-packages
```

### Building all rpm packages

``` sh
make rpm-packages
```

### Building a single package

1. Find the `target_name` of the desired package from the packages directory.

1. Build the package:

  ``` sh
  make <target_name>
  ```
