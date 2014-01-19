require 'test_helper'
require 'test/unit'

require_relative 'mocks/controllers'

ActionController::Routing::Routes.clear!
ActionController::Routing::Routes.draw {|m| m.connect ':controller/:action/:id' }

class ExceptionNotifyFunctionalDefaultSilentTest < ActionController::TestCase
  tests DefaultSilentExceptions

  @@delivered_mail = []
  cattr_accessor :delivered_mail
  include SenTestHelpers

  def setup
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    ActionController::Base.consider_all_requests_local = false
    ActionMailer::Base.class_eval do
      def deliver!(mail = @mail)
        ExceptionNotifyFunctionalDefaultSilentTest.delivered_mail << mail
      end
    end
  end

  def teardown
    ExceptionNotifyFunctionalDefaultSilentTest.delivered_mail = []
    ActionController::Base.consider_all_requests_local = false
  end

  def test_controller_with_default_silent_exceptions
    @controller = DefaultSilentExceptions.new
    get "unknown_controller"
    assert_nothing_mailed
  end

  private

  def assert_nothing_mailed
    assert @@delivered_mail.empty?, "Expected to have NOT mailed out a notification about an error occurring, but mailed: \n#{@@delivered_mail}"
  end

end
