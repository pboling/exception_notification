require "action_mailer"
module ExceptionNotification
  autoload :ExceptionNotifiable, 'exception_notification/exception_notifiable'
  autoload :Notifiable, 'exception_notification/notifiable'
  autoload :Notifier, 'exception_notification/notifier'
  #autoload :NotifierHelper, 'exception_notifiable/notifier_helper'
  autoload :ConsiderLocal,  'exception_notification/consider_local'
  autoload :CustomExceptionClasses,  'exception_notification/custom_exception_classes'
  autoload :CustomExceptionMethods,  'exception_notification/custom_exception_methods'
  autoload :HelpfulHashes,  'exception_notification/helpful_hashes'
  autoload :GitBlame,  'exception_notification/git_blame'
  autoload :DeprecatedMethods,  'exception_notification/deprecated_methods'
  autoload :HooksNotifier,  'exception_notification/hooks_notifier'
  autoload :NotifiableHelper,  'exception_notification/notifiable_helper'
end
