name 'sumologic-otel-collector'
maintainer 'Sumo Logic'
maintainer_email 'collection@sumologic.com'
issues_url 'https://github.com/SumoLogic/sumologic-otel-collector-packaging/issues' if respond_to?(:issues_url)
source_url 'https://github.com/SumoLogic/sumologic-otel-collector-packaging/tree/main/examples/chef' if respond_to?(:source_url)
license 'Apache-2.0'
description 'Installs sumologic-otel-collector'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '1.0.0'
chef_version '>= 11' if respond_to?(:chef_version)

%w[
  debian
  ubuntu
  centos
  redhat
  amazon
  windows
  suse
].each do |os|
  supports os
end

# Chef Vault support is optional; ensure the `chef-vault` gem is available in the environment when using it.
gem 'chef-vault', '~> 4.0'
