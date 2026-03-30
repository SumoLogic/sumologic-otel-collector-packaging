# Contributing to Sumo Logic OpenTelemetry Collector Packaging

Thank you for your interest in contributing to the Sumo Logic OpenTelemetry Collector Packaging project! This document provides guidelines and information for contributors.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [How to Contribute](#how-to-contribute)
- [Development Workflow](#development-workflow)
- [Building and Testing](#building-and-testing)
- [Submitting Changes](#submitting-changes)
- [Reporting Issues](#reporting-issues)
- [Community](#community)

## Code of Conduct

This project follows the Sumo Logic Code of Conduct. By participating, you are expected to uphold this code. Please report unacceptable behavior to the project maintainers.

## Getting Started

### Prerequisites

- [CMake](https://cmake.org/) (version 3.x or higher)
- [Docker](https://www.docker.com/) (for containerized builds)
- Git
- For local builds, platform-specific dependencies:
  - Linux: `dpkg`, `rpmbuild`, etc.
  - macOS: Xcode command line tools
  - Windows: WiX Toolset for MSI builds

### Clone the Repository

```bash
git clone https://github.com/SumoLogic/sumologic-otel-collector-packaging.git
cd sumologic-otel-collector-packaging
```

## How to Contribute

We welcome contributions in the following areas:

- **Bug fixes**: Fix issues in packaging scripts, install scripts, or configurations
- **New package targets**: Add support for new platforms or distributions
- **Documentation**: Improve README files, add examples, or clarify instructions
- **Configuration management**: Enhance Chef, Ansible, or Puppet examples
- **Install scripts**: Improve installation scripts for various platforms
- **Testing**: Add or improve test coverage

## Development Workflow

### 1. Fork the Repository

Fork the repository to your GitHub account and clone your fork:

```bash
git clone https://github.com/YOUR_USERNAME/sumologic-otel-collector-packaging.git
cd sumologic-otel-collector-packaging
git remote add upstream https://github.com/SumoLogic/sumologic-otel-collector-packaging.git
```

### 2. Make Your Changes

Make your changes following these guidelines:

- Follow existing code style and conventions
- Keep changes focused and atomic
- Write clear, descriptive commit messages
- Add or update documentation as needed
- Test your changes thoroughly

### 3. Commit Your Changes

Write clear and meaningful commit messages:

```bash
git add .
git commit -m "brief description of changes"
```

Commit message format:

```text
<type>: <subject>

<body>

<footer>
```

Types: `feat`, `fix`, `docs`, `chore`, `test`, `refactor`

Example:

```text
fix: correct systemd service restart logic in Chef cookbook

The Chef resource was attempting to restart the service before it was
fully initialized, causing failures on Windows. Remove the restart
action from the resource and rely on the recipe's service resource
to properly manage the service state.

Fixes #123
```

## Building and Testing

### View Available Build Targets

```bash
find targets -name '*.cmake' -exec basename -s .cmake {} \;
```

### Set Required Environment Variables

```bash
export TARGET=otc_linux_amd64_deb  # or your target
export OTC_VERSION=0.148.0
export OTC_SUMO_VERSION=0
export OTC_BUILD_NUMBER=1
```

### Build Using Docker (Recommended)

**NOTE:** This method only supports building deb & rpm packages.

1. First bake and load the image:

   ```sh
   docker buildx bake --load
   ```

2. Build the Makefile:

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

3. Build the package:

   ```sh
   docker run \
     -v $(pwd):/src \
     -v $(pwd)/build:/build \
     otelcol-sumo/cmake \
     make package
   ```

### Build Locally

Building locally requires dependencies that will differ based on your platform and the packages that you are trying to build. You will need [CMake](https://cmake.org/download/) to get started.

1. Build the Makefile:

   ```sh
   cd build && cmake ../
   ```

2. Build the package:

   ```sh
   make package
   ```

### Testing Configuration Management Examples

#### Chef

For detailed Chef cookbook contribution guidelines, see [examples/chef/sumologic-otel-collector/CONTRIBUTING.md](examples/chef/sumologic-otel-collector/CONTRIBUTING.md).

Quick testing with chef-solo:

```bash
cd examples/chef

# Create attributes file
cat > my-sumologic-wrapper/attributes/default.rb <<EOF
default['sumologic_otel_collector']['installation_token'] = 'YOUR_TOKEN'
default['sumologic_otel_collector']['collector_tags'] = {
  'environment' => 'test'
}
EOF

# Run with chef-solo
sudo chef-solo -o 'recipe[my-sumologic-wrapper]' --config-option cookbook_path=$(pwd)
```

#### Ansible

See [examples/ansible/README.md](examples/ansible/README.md)

#### Puppet

See [examples/puppet/README.md](examples/puppet/README.md)

## Submitting Changes

### Before Submitting a Pull Request

1. **Sync with upstream**:

   ```bash
   git fetch upstream
   git rebase upstream/main
   ```

2. **Run linters** (if applicable):

   ```bash
   # GitHub Actions will run actionlint
   actionlint .github/workflows/*.yml
   ```

3. **Test your changes** on relevant platforms

4. **Update documentation** if needed

### Create a Pull Request

1. Push your branch to your fork:

   ```bash
   git push origin feature/your-feature-name
   ```

2. Go to the [original repository](https://github.com/SumoLogic/sumologic-otel-collector-packaging) and create a pull request

3. Fill out the pull request template with:

   - Clear description of changes
   - Related issue numbers (if applicable)
   - Testing performed
   - Screenshots (if UI changes)

### Pull Request Guidelines

- Keep PRs focused on a single concern
- Ensure CI checks pass
- Respond to review feedback promptly
- Update your PR if the base branch has changed
- Keep the commit history clean (squash if needed)

### Review Process

- Code owners will automatically be assigned for review
- At least one approval is required before merging
- CI/CD checks must pass
- All review comments must be addressed

## Reporting Issues

### Before Creating an Issue

1. Search existing issues to avoid duplicates
2. Check the documentation and README
3. Verify you're using the latest version

### Creating a Good Issue

Include the following information:

- **Clear title**: Describe the issue concisely
- **Description**: Provide detailed information
- **Steps to reproduce**: For bugs, include exact steps
- **Expected behavior**: What should happen
- **Actual behavior**: What actually happens
- **Environment**:
  - OS and version
  - Package type (deb, rpm, msi, etc.)
  - OTC version
  - Configuration management tool (Chef, Ansible, Puppet)
- **Logs**: Include relevant error messages or logs
- **Screenshots**: If applicable

### Issue Templates

Use the provided issue templates in `.github/ISSUE_TEMPLATE/` when available.

## Community

- **Maintainers**: @SumoLogic/open-source-collection-team, @SumoLogic/sensu-team
- **GitHub Issues**: For bug reports and feature requests
- **Pull Requests**: For code contributions

## Additional Resources

- [Main README](README.md) - Project overview and build instructions
- [Examples](examples/) - Configuration management examples
- [Install Script](install-script/) - Installation script documentation
- [Sumo Logic OpenTelemetry Collector](https://github.com/SumoLogic/sumologic-otel-collector) - The collector itself

## License

By contributing to this project, you agree that your contributions will be licensed under the Apache License 2.0. See the [LICENSE](LICENSE) file for details.

## Questions?

If you have questions that aren't covered in this guide, please:

1. Check existing issues for similar questions
2. Open a new issue with the "question" label
3. Reach out to the maintainers

Thank you for contributing to Sumo Logic OpenTelemetry Collector Packaging!
