Gem::Specification.new do |spec|
  spec.name        = 'puppet-lint-param-docs'
  spec.version     = '1.7.6'
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

  spec.required_ruby_version = '>= 2.7.0'

  spec.add_dependency             'puppet-lint', '>= 3', '< 5'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rspec-its', '~> 1.0'
  spec.add_development_dependency 'rspec-collection_matchers', '~> 1.0'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'simplecov-console'
  spec.add_development_dependency 'codecov'
end
