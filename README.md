# Super Exception Notifier

**NOTE: This is a legacy gem, for rails 2.x**

The Super Exception Notifier (SEN) gem provides a mailer object and a default set of templates for sending email notifications when errors occur in a Rails application, as well as a default set of error page templates to render based on the status code assigned to an error.

| Project                 |  Super Exception Notifier   |
|------------------------ | ----------------- |
| gem name                |  super_exception_notifier   |
| license                 |  MIT              |
| moldiness               |  [![Maintainer Status](http://stillmaintained.com/pboling/exception_notification.png)](http://stillmaintained.com/pboling/exception_notification) |
| version                 |  [![Gem Version](https://badge.fury.io/rb/super_exception_notifier.png)](http://badge.fury.io/rb/super_exception_notifier) |
| dependencies            |  [![Dependency Status](https://gemnasium.com/pboling/exception_notification.png)](https://gemnasium.com/pboling/exception_notification) |
| code quality            |  [![Code Climate](https://codeclimate.com/github/pboling/exception_notification.png)](https://codeclimate.com/github/pboling/exception_notification) |
| continuous integration  |  [![Build Status](https://secure.travis-ci.org/pboling/exception_notification.png?branch=master)](https://travis-ci.org/pboling/exception_notification) |
| test coverage           |  [![Coverage Status](https://coveralls.io/repos/pboling/exception_notification/badge.png)](https://coveralls.io/r/pboling/exception_notification) |
| homepage                |  [https://github.com/pboling/exception_notification][homepage] |
| documentation           |  [http://rdoc.info/github/pboling/exception_notification/frames][documentation] |
| author                  |  [Peter Boling](https://coderbits.com/pboling) |
| Spread ~♡ⓛⓞⓥⓔ♡~      |  [![Endorse Me](https://api.coderwall.com/pboling/endorsecount.png)](http://coderwall.com/pboling) |

## Summary

The gem is configurable, allowing programmers to customize (settings are per environment or per class):

* the sender address of the email
* the recipient addresses
* text used to prepend and append the subject line
* the HTTP status codes to send emails for
* the error classes to send emails for
* alternatively, the error classes to not send emails for
* whether to send error emails or just render without sending anything
* the HTTP status and status code that gets rendered with specific errors
* the view path to the error page templates
* custom errors, with custom error templates
* fine-grained customization of error layouts (or no layout)
* get error notification for errors that occur in the console, using notifiable method
* Hooks into `git blame` output so you can get an idea of who (may) have introduced the bug
* Hooks into other website services (e.g. you can send exceptions to to Switchub.com)
* Specify which level of notification you would like with an array of optional styles of notification:
 [:render, :email, :web_hooks]
* Can notify of errors occurring in any method in any class in Ruby by wrapping the method call like this:
 notifiable { method }
* Can notify of errors in Rake tasks using 'NotifiedTask.new' instead of 'task' when writing tasks
* Works with Hoptoad Notifier, so you can notify via SEN and/or Hoptoad for any particular errors.
* Tested with Rails 2.3.x, should work with Rails 2.2.x, and is apparently **not compatible with Rails 3 or 4**.

The email includes information about the current request, session, and environment, and also gives a backtrace of the exception.

This gem is based on the wonderful exception_notification plugin created by Jamis Buck. I have modified it extensively and merged many of the improvements from a dozen or so other forks.  It remains a (mostly) drop in replacement with greatly extended functionality and customization options.  I keep it up to date with the work on the core team's
branch.

The venerable [original is here](http://github.com/rails/exception_notification)

The current version of this gem is a git fork of the original and has been updated to include the latest improvements from the original, and many improvements from the other forks on github.  I merge them in when I have time, and when the changes fit nicely with the enhancements I have already made.

This fork of Exception Notifier is (or was at some point) in production use on several large websites (top 5000).

## Installation as RubyGem

    [sudo] gem install super_exception_notifier

More Installation Options are here: http://wiki.github.com/pboling/exception_notification/installation

## Configuration as RubyGem in Rails 2.x

(UPGRADE NOTE: The name of the lib changed from SEN version 2.x to 3.x)

    config.gem 'super_exception_notifier', :lib => "exception_notification"

More Configuration Options are here: http://wiki.github.com/pboling/exception_notification/configuration

## Configuration In Environment (Initializer)

(UPGRADE NOTE: The class invoked here changed from SEN version 2.x to 3.x)

    ExceptionNotification::Notifier.configure_exception_notifier do |config|
      config[:app_name]                 = "[MYAPP]"
      config[:sender_address]           = "super.exception.notifier@example.com"
      config[:exception_recipients]     = [] # You need to set at least one recipient if you want to get the notifications
      # In a local environment only use this gem to render, never email
      #defaults to false - meaning by default it sends email.  Setting true will cause it to only render the error pages, and NOT email.
      config[:skip_local_notification]  = true
      # Error Notification will be sent if the HTTP response code for the error matches one of the following error codes
      config[:notify_error_codes]   = %W( 405 500 503 )
      # Error Notification will be sent if the error class matches one of the following error classes
      config[:notify_error_classes] = %W( )
      # What should we do for errors not listed?
      config[:notify_other_errors]  = true
      # If you set this SEN will attempt to use git blame to discover the person who made the last change to the problem code
      config[:git_repo_path]            = nil # ssh://git@blah.example.com/repo/webapp.git
    end

More Configuration Options: [http://wiki.github.com/pboling/exception_notification/advanced-environment-configuration](http://wiki.github.com/pboling/exception_notification/advanced-environment-configuration)

## Handling Errors in Request Cycle

1. Include the ExceptionNotification::ExceptionNotifiable mixin in whichever controller you want to generate error emails (typically ApplicationController) as below.

2. Specify the email recipients in your environment as above. (You may have already done this in the "Configuration in Environment (Initializer)" section above):

3. Make sure you have your ActionMailer server settings correct if you are using the e-mail features.

4. That’s it! The defaults take care of the rest.

Code:

    class ApplicationController < ActionController::Base
      ############################################################
      # ERROR HANDLING et Foo
      include ExceptionNotification::ExceptionNotifiable
      #Comment out the line below if you want to see the normal rails errors in normal development.
      alias :rescue_action_locally :rescue_action_in_public if Rails.env == 'development'
      #self.error_layout = 'errors'
      self.exception_notifiable_verbose = true #SEN uses logger.info, so won't be verbose in production
      self.exception_notifiable_pass_through = :hoptoad # requires the standard hoptoad gem to be installed, and setup normally
      self.exception_notifiable_silent_exceptions = [Acl9::AccessDenied, MethodDisabled, ActionController::RoutingError ]
      #specific errors can be handled by something else:
      rescue_from 'Acl9::AccessDenied', :with => :access_denied
      # END ERROR HANDLING
      ############################################################
      ...
    end

    ExceptionNotification::Notifier.configure_exception_notifier do |config|
      config[:exception_recipients] = %w(joe@example.com bill@example.com)
    end

[http://wiki.github.com/pboling/exception_notification/exceptions-inside-request-cycle](http://wiki.github.com/pboling/exception_notification/exceptions-inside-request-cycle)

## Advanced Configuration

There is a lot more you can configure, and do:

[http://wiki.github.com/pboling/exception_notification/](http://wiki.github.com/pboling/exception_notification/)


## Authors

[Peter Boling][peterboling] is the original author of the code, and current maintainer.

## Contributors

See the [Network View](https://github.com/pboling/exception_notification/network) and the [CHANGELOG](https://github.com/pboling/exception_notification/blob/master/CHANGELOG.txt)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
6. Create new Pull Request

## Versioning

This library aims to adhere to [Semantic Versioning 2.0.0][semver].
Violations of this scheme should be reported as bugs. Specifically,
if a minor or patch version is released that breaks backward
compatibility, a new version should be immediately released that
restores compatibility. Breaking changes to the public API will
only be introduced with new major versions.

As a result of this policy, you can (and should) specify a
dependency on this gem using the [Pessimistic Version Constraint][pvc] with two digits of precision.

For example:

    spec.add_dependency 'super_exception_notifier', '~> 3.0.14'

## References

* [Source Code](http://github.com/pboling/exception_notification)
* [A fork from the my original source on Google Code](https://github.com/vitaliel/super_exception_notifier)
* [The Original Source on Google Code](http://super-exception-notifier.googlecode.com/svn/trunk/super_exception_notifier/)
* [Getting it to work on Stack Overflow & my response](http://stackoverflow.com/questions/1738017/getting-super-exception-notifier-to-work)
* [Getting it to work on PasteBin](http://pastebin.com/pyHQjN84)

## Legal

* MIT License - See LICENSE file in this project
* Copyright (c) 2008-2014 [Peter H. Boling][peterboling] of [Rails Bling][railsbling]

[semver]: http://semver.org/
[pvc]: http://docs.rubygems.org/read/chapter/16#page74
[railsbling]: http://www.railsbling.com
[peterboling]: http://www.peterboling.com
[documentation]: http://rdoc.info/github/pboling/exception_notification/frames
[homepage]: https://github.com/pboling/exception_notification
