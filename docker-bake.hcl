group "default" {
  targets = ["cmake", "cmake-el9"]
}

target "cmake" {
  dockerfile = "Dockerfile"
  tags = ["otelcol-sumo/cmake"]
}

target "cmake-el9" {
  dockerfile = "Dockerfile.el9"
  tags = ["otelcol-sumo/cmake-el9"]
}
