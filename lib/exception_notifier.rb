require 'pathname'
require 'net/http'
require 'uri'

# Copyright (c) 2005 Jamis Buck
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
class ExceptionNotifier < ActionMailer::Base
  @@sender_address = %("Exception Notifier" <exception.notifier@default.com>)
  cattr_accessor :sender_address

  @@exception_recipients = []
  cattr_accessor :exception_recipients

  @@email_prefix = "[ERROR] "
  cattr_accessor :email_prefix

  @@sections = %w(request session environment backtrace)
  cattr_accessor :sections
  
  @@web_hooks = []
  cattr_accessor :web_hooks
  
  self.template_root = "#{File.dirname(__FILE__)}/../views"

  def self.reloadable?() false end

  def exception_notification(exception, controller, request, data={})
    content_type "text/plain"

    subject    "#{email_prefix}#{controller.controller_name}##{controller.action_name} (#{exception.class}) #{exception.message.inspect}"

    recipients exception_recipients
    from       sender_address

    body       data.merge({ :controller => controller, :request => request,
                  :exception => exception, :host => (request.env["HTTP_X_FORWARDED_HOST"] || request.env["HTTP_HOST"]),
                  :backtrace => sanitize_backtrace(exception.backtrace),
                  :rails_root => rails_root, :data => data,
                  :sections => sections })
  end
  
  # Deliver exception data hash to web hooks, if any
  #
  def send_exception_to_web_hooks(exception, controller, request, data={})
    params = build_web_hook_params(exception, controller, request, data)
    web_hooks.each do |address|
      post_hook(params, address)
    end
  end
  
  private
  
  # Parameters hash based on Merb Exceptions example
  #
  def build_web_hook_params(exception, controller, request, data={})
    host = (request.env["HTTP_X_FORWARDED_HOST"] || request.env["HTTP_HOST"])
    backtrace = sanitize_backtrace(exception.backtrace)
    {
      'request_url'              => "#{request.protocol}#{host}#{request.request_uri}",
      'request_controller'       => controller.class.name,
      'request_action'           => details['params'][:action],
      'request_params'           => request.parameters.inspect,
      'environment'              => RAILS_ENV,
      'exceptions'               => {
        :class      => exception.class.to_s,
        :backtrace  => backtrace,
        :status     => exception.status if exception.respond_to?(:status),
        :message    => exception.message
        },
        'app_name'                 => 'unknown',
        'version'                  => 'unknown',
      }
    end
    
    def post_hook(params, address)
      uri = URI.parse(address)
      uri.path = '/' if uri.path=='' # set a path if one isn't provided to keep Net::HTTP happy
      Net::HTTP.post_form( uri, params ).body
    end
        
    def sanitize_backtrace(trace)
      re = Regexp.new(/^#{Regexp.escape(rails_root)}/)
      trace.map { |line| Pathname.new(line.gsub(re, "[RAILS_ROOT]")).cleanpath.to_s }
    end

    def rails_root
      @rails_root ||= Pathname.new(RAILS_ROOT).cleanpath.to_s
    end

end
