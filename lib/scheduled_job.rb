# A variant on the hash that JobList keeps. Scheduled jobs contain their own time/schedule data.
module Whenever
  class ScheduledJob
    delegate :task, :at, :to => :job
    attr_reader :job, :time
    
    def initialize(job, time)
      @job = job
      @time = time
    end
    
    def schedule
      returning ret = '' do
        ret << "every #{@time.inspect}"
        if at.is_a?(String)
          ret << " at #{at}"
        elsif at.is_a?(Time)
          ret << " at #{at.to_s(:date_and_time)}"
        end
      end
    end
    
    def schedule_data
      { :frequency => frequency_num, :interval => frequency_interval, :at => at }
    end
    
    # Given 2.days as frequency returns {:days => 2}
    def frequency_parts
      # Lifted from ActiveSupport::Duration#inspect
      @time.parts.inject(::Hash.new(0)) { |h,part| h[part.first] += part.last; h }
    end
    
    # Given 2.days as frequency returns 2
    def frequency_num
      frequency_parts.values.first
    end
    
    # Given 2.days as frequency returns 'days'
    def frequency_interval
      interval = frequency_parts.keys.first.to_s
      frequency_num == 1 ? interval.singularize : interval
    end
  end
end