require 'test/unit'
require 'bundler'
require 'bundler/setup'

Bundler.require(:default, :test)

require 'rake'
require 'rake/tasklib'
require 'action_mailer'
require 'active_record'

#just requiring active record wasn't loading classes soon enough for SILENT_EXCEPTIONS
ActiveRecord::Base

require 'action_controller'
require 'action_controller/test_case'
require 'action_controller/test_process'

#just requiring action controller wasn't loading classes soon enough for SILENT_EXCEPTIONS
ActionController::Base

RAILS_ROOT = '.' unless defined?(RAILS_ROOT)
RAILS_ENV = 'test' unless defined?(RAILS_ENV)
RAILS_DEFAULT_LOGGER = Logger.new(StringIO.new) unless defined?(RAILS_DEFAULT_LOGGER)
#$:.unshift File.join(File.dirname(__FILE__), '../lib')

#require File.join(File.dirname(__FILE__), "..", "init")
require 'require_relative'

# For code coverage, must be required before all application / gem / library code.
if RUBY_VERSION >= "1.9.2"
  require 'coveralls'
  Coveralls.wear!
end

require_relative '../init'

ExceptionNotification::Notifier.configure_exception_notifier do |config|
  # If left empty web hooks will not be engaged
  config[:web_hooks]                = []
  config[:exception_recipients]     = ["test.errors@example.com"]
  config[:view_path]                = File.join(File.dirname(__FILE__), "mocks")
  config[:skip_local_notification]  = false
  config[:notify_other_errors]      = true
end
