#!/usr/bin/env rake
require "bundler/gem_tasks"
require 'rake'
require 'rake/testtask'

desc 'Default: run unit tests.'
task :default => :test

desc 'Test exception_notifiable gem.'
Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/*_test.rb']
  t.verbose = true
end

namespace :test do
  desc 'Test against all supported Rails versions'
  task :all do
    %w(2.2.x 2.3.x).each do |version|
      sh "BUNDLE_GEMFILE='gemfiles/Gemfile.rails-#{version}' bundle --quiet"
      sh "BUNDLE_GEMFILE='gemfiles/Gemfile.rails-#{version}' bundle exec rake test"
    end
  end
end

require 'reek/rake/task'
Reek::Rake::Task.new do |t|
  t.fail_on_error = true
  t.verbose = false
  t.source_files = 'lib/**/*.rb'
end

require 'roodi'
require 'roodi_task'
RoodiTask.new do |t|
  t.verbose = false
end


desc 'Generate documentation for exception_notifiable gem.'
require File.expand_path('../lib/super_exception_notifier/version', __FILE__)
require 'rdoc'
require 'rdoc/task'
RDoc::Task.new do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = "exception_notifiable #{SuperExceptionNotifier::VERSION}"
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README.md')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

Bundler::GemHelper.install_tasks
