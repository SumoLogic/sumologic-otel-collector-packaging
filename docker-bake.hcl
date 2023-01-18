group "default" {
  targets = ["cmake"]
}

target "cmake" {
  dockerfile = "Dockerfile"
  tags = ["otelcol-sumo/cmake"]
}
