require 'test_helper'
require 'test/unit'

require_relative 'mocks/controllers'

ActionController::Routing::Routes.clear!
ActionController::Routing::Routes.draw {|m| m.connect ':controller/:action/:id' }

class ExceptionNotifyFunctionalCustomSilentTest < ActionController::TestCase
  tests CustomSilentExceptions

  @@delivered_mail = []
  cattr_accessor :delivered_mail
  include SenTestHelpers

  def setup
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    ActionController::Base.consider_all_requests_local = false
    ActionMailer::Base.class_eval do
      def deliver!(mail = @mail)
        ExceptionNotifyFunctionalCustomSilentTest.delivered_mail << mail
      end
    end
  end

  def teardown
    ExceptionNotifyFunctionalCustomSilentTest.delivered_mail = []
    ActionController::Base.consider_all_requests_local = false
  end

  def test_controller_with_custom_silent_exceptions
    @controller = CustomSilentExceptions.new
    get "runtime_error"
    assert_nothing_mailed
  end

  private

  def assert_nothing_mailed
    assert @@delivered_mail.empty?, "Expected to have NOT mailed out a notification about an error occuring, but mailed: \n#{@@delivered_mail}"
  end

end
