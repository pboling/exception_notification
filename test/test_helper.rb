require 'test/unit'
require 'rubygems'
require 'active_support'
require 'actionmailer'

RAILS_ROOT = '.' unless defined?(RAILS_ROOT)
RAILS_DEFAULT_LOGGER = Logger.new(StringIO.new)
$:.unshift File.join(File.dirname(__FILE__), '../lib')

require 'exception_notifier'

class ExceptionNotifier
  def deliver!; end
end
