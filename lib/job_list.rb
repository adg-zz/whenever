module Whenever
  class JobList

    def initialize(options)
      @jobs = Hash.new
      @env  = Hash.new

      config = case options
        when String then options
        when Hash
          if options[:string]
            options[:string]
          elsif options[:file]
            @filename = options[:file]
            file_read = File.read(@filename)
          end
      end
      
      if file_read
        eval(ERB.new(file_read).result(binding))
      else
        eval(config)
      end
    end
    
    def set(variable, value)
      instance_variable_set("@#{variable}".to_sym, value)
      self.class.send(:attr_reader, variable.to_sym)
    end

    def env(variable, value)
      @env[variable.to_s] = value
    end

    def every(frequency, options = {})
      @current_time_scope = frequency
      @options = options
      yield
    end

    def command(task, options = {})
      options[:cron_log] ||= @cron_log unless options[:cron_log] === false
      options[:class]    ||= Whenever::Job::Default
      @jobs[@current_time_scope] ||= []
      @jobs[@current_time_scope] << options[:class].new(@options.merge(:task => task).merge(options))
    end

    def runner(task, options = {})
      options.reverse_merge!(:environment => @environment, :path => @path)
      options[:class] = Whenever::Job::Runner
      command(task, options)
    end

    def rake(task, options = {})
      options.reverse_merge!(:environment => @environment, :path => @path)
      options[:class] = Whenever::Job::RakeTask
      command(task, options)
    end

    def generate_cron_output
      [environment_variables, cron_jobs].compact.join
    end

    def scheduled_jobs
      @scheduled_jobs ||= begin
        returning scheduled = [] do
          @jobs.each do |time, jobs|
            jobs.each do |j|
              scheduled << ScheduledJob.new(j, time)
            end
          end
        end
      end
    end

    def schedule_for_task(task)
      scheduled_job = scheduled_job_for_task(task)
      scheduled_job ? scheduled_job.schedule : "Schedule for #{task} not found"
    end

    def schedule_data_for_task(task)
      if scheduled_job = scheduled_job_for_task(task)
        scheduled_job.schedule_data
      end
    end

    # Expect arguments in form:
    # - task: "Otl::Eirb::ProtocolJob" # => class name as string
    # - schedule: {"interval"=>"days", "frequency"=>"2", "at"=>"10:00pm"}
    def update_schedule_for_task(task, schedule)
      lines = File.readlines(@filename)
      lines.each_with_index do |line, i|
        if line.include?(task)
          j = i - 1
          until lines[j] =~ /^every/
            j -= 1
          end
          lines[j] = "every #{schedule['frequency']}.#{schedule['interval']}, :at => '#{schedule['at']}' do\n"
          File.open(@filename, 'w') do |f|
            lines.each do |line|
              f.write(line)
            end
          end
        end
      end
      scheduled_job_for_task(task)
    end

    def scheduled_job_for_task(task)
      scheduled_jobs.detect { |sj| sj.task =~ Regexp.new(task) }
    end

  private

    def environment_variables
      return if @env.empty?

      output = []
      @env.each do |key, val|
        output << "#{key}=#{val}\n"
      end
      output << "\n"

      output.join
    end

    def cron_jobs
      return if @jobs.empty?

      output = []
      @jobs.each do |time, jobs|
        jobs.each do |job|
          cron = Whenever::Output::Cron.output(time, job)
          cron << " >> #{job.cron_log} 2>&1" if job.cron_log
          cron << "\n\n"
          output << cron
        end
      end

      output.join
    end

  end
end