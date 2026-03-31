# Contributing to Sumo Logic OpenTelemetry Collector Chef Cookbook

Thank you for your interest in contributing to the Chef cookbook for Sumo Logic OpenTelemetry Collector!

## General Contributing Guidelines

Please refer to the [main CONTRIBUTING.md](../../../CONTRIBUTING.md) file in the root of this repository for general contribution guidelines, including:

- Code of Conduct
- Development Workflow
- Submitting Changes
- Pull Request Guidelines
- Reporting Issues

## Chef Cookbook Specific Guidelines

### Prerequisites

- [Chef Workstation](https://www.chef.io/downloads/tools/workstation) or Chef Client with chef-solo
- Ruby knowledge for writing Chef recipes and resources
- Understanding of Chef DSL (Domain Specific Language)

### Testing the Cookbook

For comprehensive testing instructions, including troubleshooting and verification steps, see [TESTING.md](TESTING.md).

#### Quick Testing with chef-solo

1. **Create a test attributes file**:

   ```bash
   mkdir -p my-sumologic-wrapper/attributes
   ```

   Create `my-sumologic-wrapper/attributes/default.rb`:

   ```ruby
   default['sumologic_otel_collector']['installation_token'] = 'YOUR_TOKEN'
   default['sumologic_otel_collector']['collector_tags'] = {
     'environment' => 'test',
     'team' => 'testing'
   }
   ```

2. **Create a test recipe**:

   Create `my-sumologic-wrapper/recipes/default.rb`:

   ```ruby
   include_recipe 'sumologic-otel-collector::default'
   ```

3. **Create metadata file**:

   Create `my-sumologic-wrapper/metadata.rb`:

   ```ruby
   name 'my-sumologic-wrapper'
   version '0.1.0'
   depends 'sumologic-otel-collector'
   ```

4. **Run chef-solo**:

   ```bash
   sudo chef-solo -o 'recipe[my-sumologic-wrapper]' --config-option cookbook_path=$(pwd)
   ```

5. **Verify installation**:

   Linux:

   ```bash
   sudo systemctl status otelcol-sumo
   sudo journalctl -u otelcol-sumo
   ```

   Windows:

   ```powershell
   Get-Service -Name OtelcolSumo
   ```

### Cookbook Structure

```text
sumologic-otel-collector/
├── attributes/        # Default attributes
├── files/            # Static files
├── recipes/          # Chef recipes
├── resources/        # Custom resources
├── metadata.rb       # Cookbook metadata
└── README.md         # Cookbook documentation
```

### Making Changes

#### When Modifying Resources

If you modify `resources/default.rb`:

1. Test on both Linux and Windows platforms
2. Ensure the resource properties are properly documented
3. Update the README.md if you add new properties
4. Test with different attribute combinations

#### When Modifying Recipes

If you modify `recipes/default.rb`:

1. Ensure backward compatibility
2. Test credential loading from all three methods:
   - Chef Vault
   - Encrypted Data Bags
   - Node Attributes
3. Verify service management works correctly

#### When Updating Attributes

If you modify `attributes/default.rb`:

1. Document new attributes in README.md
2. Provide sensible defaults
3. Test with attributes unset to ensure defaults work

### Platform Support

This cookbook supports:

- **Linux**: Ubuntu, Debian, RHEL, CentOS, Amazon Linux, Fedora
- **Windows**: Windows Server 2016+, Windows 10+

When making changes, consider cross-platform compatibility:

- Use `platform_family?` checks for platform-specific code
- Test systemd service management on Linux
- Test Windows service management on Windows
- Use Chef's built-in resources when possible

### Coding Style

Follow these Chef best practices:

- Use Chef's unified mode (`unified_mode true`)
- Prefer custom resources over LWRPs
- Use `action :default` as the primary action
- Write clear resource property descriptions
- Use meaningful variable names
- Add comments for complex logic

### Example Contribution Workflow

1. Fork the repository and create a branch
2. Make your changes to the cookbook
3. Test locally with chef-solo:

   ```bash
   sudo chef-solo -o 'recipe[sumologic-otel-collector]' --config-option cookbook_path=$(pwd)
   ```

4. Verify the service is running:

   ```bash
   sudo systemctl status otelcol-sumo  # Linux
   Get-Service OtelcolSumo              # Windows
   ```

5. Update documentation in README.md
6. Commit with clear messages following the main [CONTRIBUTING.md](../../../CONTRIBUTING.md) guidelines
7. Submit a pull request

### Documentation

When adding features:

- Update [README.md](README.md) with new attributes or usage examples
- Add inline comments for complex resource logic
- Include examples in the README for new functionality

### Testing Checklist

Before submitting a pull request, verify (see [TESTING.md](TESTING.md) for detailed procedures):

- [ ] Cookbook works with chef-solo on Linux
- [ ] Cookbook works with chef-solo on Windows (if applicable)
- [ ] All attributes are documented in README.md
- [ ] Resource properties are properly defined
- [ ] Service starts successfully after installation
- [ ] Collector is sending data to Sumo Logic
- [ ] Changes are backward compatible
- [ ] No hardcoded tokens or sensitive data
- [ ] Code follows Chef best practices

## Questions?

For Chef cookbook-specific questions:

1. Check the [README.md](README.md) for usage examples
2. Review existing [issues](https://github.com/SumoLogic/sumologic-otel-collector-packaging/issues)
3. Ask in your pull request or issue

For general contribution questions, see the [main CONTRIBUTING.md](../../../CONTRIBUTING.md).

Thank you for contributing!
