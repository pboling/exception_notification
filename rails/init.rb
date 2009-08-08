require "action_mailer"

require File.join(File.dirname(__FILE__), '..', 'lib', "super_exception_notifier", "custom_exception_classes")
require File.join(File.dirname(__FILE__), '..', 'lib', "super_exception_notifier", "custom_exception_methods")

$:.unshift "#{File.dirname(__FILE__)}/lib"

require "exception_notifier"
require "exception_notifiable"
require "exception_notifier_helper"
require "notifiable"

Object.class_eval do include Notifiable end
