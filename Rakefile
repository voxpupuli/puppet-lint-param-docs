require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

begin
  require 'rubygems'
  require 'github_changelog_generator/task'

  GitHubChangelogGenerator::RakeTask.new :changelog do |config|
    config.exclude_labels = %w{duplicate question invalid wontfix wont-fix skip-changelog}
    config.user = 'voxpupuli'
    config.project = 'puppet-lint-param-docs'
    gem_version = Gem::Specification.load("#{config.project}.gemspec").version
    config.future_release = "v#{gem_version}"
  end
rescue LoadError
end
