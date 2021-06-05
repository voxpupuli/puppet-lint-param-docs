Gem::Specification.new do |spec|
  spec.name        = 'puppet-lint-param-docs'
  spec.version     = '1.7.3'
  spec.homepage    = 'https://github.com/voxpupuli/puppet-lint-param-docs'
  spec.license     = 'MIT'
  spec.author      = 'Vox Pupuli'
  spec.email       = 'voxpupuli@groups.io'
  spec.files       = Dir[
    'README.md',
    'LICENSE',
    'lib/**/*',
    'spec/**/*',
  ]
  spec.test_files  = Dir['spec/**/*']
  spec.summary     = 'puppet-lint check to validate all parameters are documented'
  spec.description = <<-EOF
    A new check for puppet-lint that validates all parameters are documented.
  EOF

  spec.add_dependency             'puppet-lint', '>= 1.1', '< 3.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rspec-its', '~> 1.0'
  spec.add_development_dependency 'rspec-collection_matchers', '~> 1.0'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'simplecov'
end
