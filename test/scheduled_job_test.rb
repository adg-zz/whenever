require File.expand_path(File.dirname(__FILE__) + "/test_helper")

class ScheduledJobTest < Test::Unit::TestCase
  context "Scheduled jobs" do
    setup do
      jobs = <<-JOBS
        every 1.day do
          runner 'foo'
        end

        every 2.days, :at => '4:30am' do
          runner 'bar'
        end
      JOBS

      @job_list = Whenever::JobList.new(:string => jobs)
      @scheduled_job_1 = @job_list.scheduled_jobs.first
      @scheduled_job_2 = @job_list.scheduled_jobs.last
    end

    should "provide whenever schedule syntax" do
      assert_equal 'every 1 day', @scheduled_job_1.schedule
      assert_equal 'every 2 days at 4:30am', @scheduled_job_2.schedule
    end
    
    should "provide frequency number" do
      assert_equal 1, @scheduled_job_1.frequency_num
      assert_equal 2, @scheduled_job_2.frequency_num
    end
    
    should "provide frequency interval" do
      assert_equal 'day', @scheduled_job_1.frequency_interval
      assert_equal 'days', @scheduled_job_2.frequency_interval
    end
    
    should "provide schedule data" do
      expected_keys = [:frequency, :interval, :at]
      schedule = @scheduled_job_2.schedule_data
      expected_keys.each do |k|
        assert schedule.keys.include?(k)
      end
      assert_equal 2, schedule[:frequency]
      assert_equal 'days', schedule[:interval]
      assert_equal '4:30am', schedule[:at]
    end
  end
end