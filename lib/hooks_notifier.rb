require 'net/http'
require 'uri'

module HooksNotifier
  # Deliver exception data hash to web hooks, if any
  #
  def self.deliver_exception_to_web_hooks(web_hooks, exception, controller, request, data={})
    params = build_web_hook_params(exception, controller, request, data)
    web_hooks.each do |address|
      post_hook(params, address)
    end
  end


  # Parameters hash based on Merb Exceptions example
  #
  def self.build_web_hook_params(exception, controller, request, data={})
    host = (request.env["HTTP_X_FORWARDED_HOST"] || request.env["HTTP_HOST"])
    p = {
      'request_url'              => "#{request.protocol}#{host}#{request.request_uri}",
      'request_controller'       => controller.class.name,
      'request_action'           => request.parameters['action'],
      'request_params'           => request.parameters.inspect,
      'environment'              => RAILS_ENV,
      'exceptions'               => [{
        :class      => exception.class.to_s,
        :backtrace  => exception.backtrace,
        :message    => exception.message
        }],
        'app_name'                 => 'unknown',
        'version'                  => 'unknown',
      }
      p[:status] = exception.status if exception.respond_to?(:status)
      p
  end

  def self.post_hook(params, address)
    uri = URI.parse(address)
    uri.path = '/' if uri.path=='' # set a path if one isn't provided to keep Net::HTTP happy
    Net::HTTP.post_form( uri, params ).body
  end

end
