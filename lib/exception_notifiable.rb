require 'ipaddr'

module ExceptionNotifiable
  # exceptions of these types will not generate notification emails
  SILENT_EXCEPTIONS = [
    ActiveRecord::RecordNotFound,
    ActionController::UnknownController,
    ActionController::UnknownAction,
    ActionController::RoutingError,
    ActionController::MethodNotAllowed
  ]

  HTTP_ERROR_CODES = { 
    "400" => "Bad Request",
    "403" => "Forbidden",
    "404" => "Not Found",
    "405" => "Method Not Allowed",
    "410" => "Gone",
    "500" => "Internal Server Error",
    "501" => "Not Implemented",
    "503" => "Service Unavailable"
  }

  def self.codes_for_rails_error_classes
    classes = {
      NameError => "503",
      TypeError => "503",
      ActiveRecord::RecordNotFound => "400" 
    }
    classes.merge!({ ActionController::UnknownController => "404" }) if ActionController.const_defined?(:UnknownController)
    classes.merge!({ ActionController::MissingTemplate => "404" }) if ActionController.const_defined?(:MissingTemplate)
    classes.merge!({ ActionController::MethodNotAllowed => "405" }) if ActionController.const_defined?(:MethodNotAllowed)
    classes.merge!({ ActionController::UnknownAction => "501" }) if ActionController.const_defined?(:UnknownAction)
    classes.merge!({ ActionController::RoutingError => "404" }) if ActionController.const_defined?(:RoutingError)
  end
  
  def self.included(base)
    base.extend ClassMethods

    # Adds the following class attributes to the classes that include ExceptionNotifiable
    #  HTTP status codes and what their 'English' status message is
    #  Rails error classes to rescue and how to rescue them
    #  error_layout:
    #     can be defined at controller level to the name of the layout, 
    #     or set to true to render the controller's own default layout, 
    #     or set to false to render errors with no layout
    base.cattr_accessor :silent_exceptions
    base.silent_exceptions = SILENT_EXCEPTIONS
	base.cattr_accessor :http_error_codes
	base.http_error_codes = HTTP_ERROR_CODES
	base.cattr_accessor :error_layout
	base.cattr_accessor :rails_error_classes
	base.rails_error_classes = self.codes_for_rails_error_classes
	base.cattr_accessor :exception_notifier_verbose
	base.exception_notifier_verbose = false
	
    base.class_eval do
      alias_method_chain :rescue_action_in_public, :notification
    end
  end
  
  module ClassMethods
    # specifies ip addresses that should be handled as though local
    def consider_local(*args)
      local_addresses.concat(args.flatten.map { |a| IPAddr.new(a) })
    end

    def local_addresses
      addresses = read_inheritable_attribute(:local_addresses)
      unless addresses
        addresses = [IPAddr.new("127.0.0.1")]
        write_inheritable_attribute(:local_addresses, addresses)
      end
      addresses
    end

    # set the exception_data deliverer OR retrieve the exception_data
    def exception_data(deliverer = nil)
      if deliverer
        write_inheritable_attribute(:exception_data, deliverer)
      else
        read_inheritable_attribute(:exception_data)
      end
    end
  end

  private

    # overrides Rails' local_request? method to also check any ip
    # addresses specified through consider_local.
    def local_request?
      remote = IPAddr.new(request.remote_ip)
      !self.class.local_addresses.detect { |addr| addr.include?(remote) }.nil?
    end

    def render_error(status_cd, request, exception, file_path = nil)
      status = self.class.http_error_codes[status_cd] ? status_cd + " " + self.class.http_error_codes[status_cd] : status_cd
      if self.class.exception_notifier_verbose
        puts "[FILE PATH] #{file_path}" if !file_path.nil?
        logger.error("render_error(#{status_cd}, #{self.class.http_error_codes[status_cd]}) invoked for request_uri=#{request.request_uri} and env=#{request.env.inspect}")
      end
      respond_to do |type|
        type.html { render :file => file_path ? ExceptionNotifier.get_view_path(file_path) : ExceptionNotifier.get_view_path(status_cd), 
                            :layout => self.class.error_layout, 
                            :status => status }
        type.all  { render :nothing => true, 
                            :status => status}
      end
      send_exception_email(exception) if ExceptionNotifier.should_send_email?(status_cd, exception)
    end

    def send_exception_email(exception)
      deliverer = self.class.exception_data
      data = case deliverer
        when nil then {}
        when Symbol then send(deliverer)
        when Proc then deliverer.call(self)
      end
      ExceptionNotifier.deliver_exception_notification(exception, self, request, data)
    end

    def rescue_action_in_public(exception)
      if self.class.exception_notifier_verbose
        puts self.class.rails_error_classes.inspect
        puts self.class.http_error_codes.inspect
        puts "[EXCEPTION] #{exception}"
        puts "[EXCEPTION CLASS] #{exception.class}"
        puts "[EXCEPTION STATUS_CD] #{self.class.rails_error_classes[exception.class]}" unless self.class.rails_error_classes[exception.class].nil?
      end
      
      # If the error class is NOT listed in the rails_errror_class hash then we get a generic 500 error:
      if self.class.rails_error_classes[exception.class].nil?
        render_error("500", request, exception)
      # OTW if the error class is listed, but has a blank code or the code is == '200' then we get a custom error layout rendered.
      elsif self.class.rails_error_classes[exception.class].blank? || self.class.rails_error_classes[exception.class] == '200'
        render_error("200", request, exception, exception.to_s.delete(':').gsub( /([A-Za-z])([A-Z])/, '\1' << '_' << '\2' ).downcase)
      # OTW the error class is listed!
      else
        render_error(self.class.rails_error_classes[exception.class], request, exception)
      end
end
