module Whenever
  module Job
    class Default
      
      attr_accessor :task, :at, :cron_log
    
      def initialize(options = {})
        @task        = options[:task]
        @at          = options[:at]
        @cron_log    = options[:cron_log]
        @environment = options[:environment] || :production
        @path        = options[:path] || Whenever.path
      end
    
      def output
        task
      end
      
      def schedule
        returning '' do |ret|
          ret << "every #{@time.inspect}"
          if @at.is_a?(String)
            ret << " at #{@at}"
          elsif @at.is_a?(Time)
            ret << " at #{@at.to_s(:date_and_time)}"
          end
        end
      end
      
    protected
      
      def path_required
        raise ArgumentError, "No path available; set :path, '/your/path' in your schedule file" if @path.blank?
      end
      
    end
  end
end