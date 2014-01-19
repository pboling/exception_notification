# -*- encoding: utf-8 -*-
require File.expand_path('../lib/super_exception_notifier/version', __FILE__)

Gem::Specification.new do |s|
  s.name = %q{super_exception_notifier}
  s.version = SuperExceptionNotifier::VERSION

  s.authors = ["Peter Boling", "Scott Windsor", "Ismael Celis", "Jacques Crocker", "Jamis Buck"]
  s.email = %w{peter.boling@gmail.com}
  s.description = %q{Allows customization of:
* Specify which level of notification you would like with an array of optional styles of notification (email, webhooks)
* the sender address of the email
* the recipient addresses
* the text used to prefix the subject line
* the HTTP status codes to notify for
* the error classes to send emails for
* alternatively, the error classes to not notify for
* whether to send error emails or just render without sending anything
* the HTTP status and status code that gets rendered with specific errors
* the view path to the error page templates
* custom errors, with custom error templates
* define error layouts at application or controller level, or use the controller's own default layout, or no layout at all
* get error notification for errors that occur in the console, using notifiable method
* Override the gem's handling and rendering with explicit rescue statements inline.
* Hooks into `git blame` output so you can get an idea of who (may) have introduced the bug
* Hooks into other website services (e.g. you can send exceptions to to Switchub.com)
* Can notify of errors occurring in any class/method using notifiable { method }
* Can notify of errors in Rake tasks using NotifiedTask.new instead of task
* Works with Hoptoad Notifier, so you can notify via SEN and/or Hoptoad for any particular errors.
* Tested with Rails 2.3.x, should work with rails 2.2.x, and is apparently not yet compatible with rails 3.}
  s.email = %q{peter.boling@gmail.com}

  s.files         = Dir.glob("{bin,lib,vendor,rails}/**/*") + %w(LICENSE README.md CHANGELOG.txt Rakefile)
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.extra_rdoc_files = [
    "CHANGELOG.txt",
    "LICENSE",
    "README.md"
  ]

  s.homepage = %q{http://github.com/pboling/exception_notification}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.summary = %q{Allows unhandled (and handled!) exceptions to be captured and sent via email}
  s.platform = Gem::Platform::RUBY
  s.licenses = ["MIT"]

  s.add_runtime_dependency(%q<actionmailer>, [">= 0","< 3"])
  s.add_development_dependency(%q<rbx-require-relative>, ["~> 0.0.9"])
  s.add_development_dependency(%q<rails>, [">= 2.3","< 3"])
  s.add_development_dependency(%q<rdoc>, [">= 3.12"])
  s.add_development_dependency(%q<rake>, [">= 0.8","< 0.9"])
  s.add_development_dependency(%q<reek>, [">= 1.2.13"])
  s.add_development_dependency(%q<roodi>, [">= 2.2.0"])

end

