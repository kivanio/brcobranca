# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'github_changelog_generator/task'

RSpec::Core::RakeTask.new(:spec)

task default: :spec

GitHubChangelogGenerator::RakeTask.new :changelog do |config|
  config.date_format = '%d-%m-%Y'
  config.user = 'kivanio'
  config.project = 'brcobranca'
end
