class NotifiedTask < Rake::TaskLib
  attr_accessor :name, :block

  def initialize(name, &block)
    @name = name
    @block = block
    define
  end

  def define
    task name do |t|
      begin
        block.call
      rescue Exception => e
        unless Rails.env.development? || Rails.env.test?
          ExceptionNotifier.deliver_rake_exception_notification(e, t) 
        end
        raise
      end
    end
  end
end
