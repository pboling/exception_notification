puts "Begin Loading ExceptionNotification"
require 'rake'
require 'rake/tasklib'
require "action_mailer"

require "exception_notification/notified_task" unless defined?(NotifiedTask)

require "exception_notification" unless defined?(ExceptionNotification)

Object.class_eval do
  include ExceptionNotification::Notifiable
end
puts "Object test: #{Object.respond_to?(:notifiable_noisy_environments) ? 'Pass' : 'Fail'}"
puts "Finished Loading ExceptionNotification"

#It appears that the view path is auto-added by rails... hmmm.
#if ActionController::Base.respond_to?(:append_view_path)
#  puts "view path before: #{ActionController::Base.view_paths}"
#  ActionController::Base.append_view_path(File.join(File.dirname(__FILE__), 'app', 'views','exception_notifiable'))
#  puts "view path After: #{ActionController::Base.view_paths}"
#end
