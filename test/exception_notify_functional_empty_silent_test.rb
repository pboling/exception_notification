require 'test_helper'
require 'test/unit'

require_relative 'mocks/controllers'

ActionController::Routing::Routes.clear!
ActionController::Routing::Routes.draw {|m| m.connect ':controller/:action/:id' }

class ExceptionNotifyFunctionalEmptySilentTest < ActionController::TestCase
  tests EmptySilentExceptions

  @@delivered_mail = []
  cattr_accessor :delivered_mail
  include SenTestHelpers

  def setup
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    ActionController::Base.consider_all_requests_local = false
    ActionMailer::Base.class_eval do
      def deliver!(mail = @mail)
        ExceptionNotifyFunctionalEmptySilentTest.delivered_mail << mail
      end
    end
  end

  def teardown
    ExceptionNotifyFunctionalEmptySilentTest.delivered_mail = []
    ActionController::Base.consider_all_requests_local = false
  end

  def test_controller_with_empty_silent_exceptions
    @controller = EmptySilentExceptions.new
    get "ar_record_not_found"
    assert_error_mail_contains("ActiveRecord::RecordNotFound")
  end

  private

  def assert_error_mail_contains(text)
    assert(mailed_error.index(text),
           "Expected mailed error body to contain '#{text}', but not found. \n actual contents: \n#{mailed_error}")
  end

  def mailed_error
    assert @@delivered_mail.last, "Expected to have mailed out a notification about an error occurring, but none mailed"
    @@delivered_mail.last.encoded
  end

end
