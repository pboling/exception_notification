require 'test_helper'
require 'test/unit'

require_relative 'mocks/controllers'

ActionController::Routing::Routes.clear!
ActionController::Routing::Routes.draw {|m| m.connect ':controller/:action/:id' }

class ExceptionNotifyFunctionalOldStyleTest < ActionController::TestCase
  tests OldStyle

  @@delivered_mail = []
  cattr_accessor :delivered_mail
  include SenTestHelpers

  def setup
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    ActionController::Base.consider_all_requests_local = false
    ActionMailer::Base.class_eval do
      def deliver!(mail = @mail)
        ExceptionNotifyFunctionalOldStyleTest.delivered_mail << mail
      end
    end
  end

  def teardown
    ExceptionNotifyFunctionalOldStyleTest.delivered_mail = []
    ActionController::Base.consider_all_requests_local = false
  end

  def test_old_style_where_requests_are_local
    OldStyle.consider_all_requests_local = true
    @controller = OldStyle.new
    get "runtime_error"
    assert_nothing_mailed
  end

  def test_old_style_runtime_error_sends_mail
    @controller = OldStyle.new
    get "runtime_error"
    assert_error_mail_contains("This is a runtime error that we should be emailed about")
  end

  def test_old_style_record_not_found_does_not_send_mail
    @controller = OldStyle.new
    get "ar_record_not_found"
    assert_nothing_mailed
  end

  private

  def assert_error_mail_contains(text)
    assert(mailed_error.index(text),
           "Expected mailed error body to contain '#{text}', but not found. \n actual contents: \n#{mailed_error}")
  end

  def assert_nothing_mailed
    assert @@delivered_mail.empty?, "Expected to have NOT mailed out a notification about an error occurring, but mailed: \n#{@@delivered_mail}"
  end

  def mailed_error
    assert @@delivered_mail.last, "Expected to have mailed out a notification about an error occurring, but none mailed"
    @@delivered_mail.last.encoded
  end

end
