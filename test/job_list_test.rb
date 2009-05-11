require File.expand_path(File.dirname(__FILE__) + "/test_helper")

class JobListTest < Test::Unit::TestCase
  
  context "A JobList for days-based jobs" do
    setup do
      @scheduled_job_1 = <<-JOB1
        every 1.day do
          runner 'foo'
        end
      JOB1
      
      @scheduled_job_2 = <<-JOB2
        every 2.days, :at => '4:30am' do
          runner 'bar'
        end
      JOB2
      
      @job_list_1 = Whenever::JobList.new(:string => @scheduled_job_1)
      @job_list_2 = Whenever::JobList.new(:string => @scheduled_job_2)
    end
    
    should "provide whenever syntax" do
      schedule = @job_list_1.schedule_for_task('foo')
      assert_match /every 1 day/, schedule
      schedule = @job_list_2.schedule_for_task('bar')
      assert_match /every 2 days/, schedule
    end
    
    should "provide frequency number" do
      assert_equal 1, @job_list_1.frequency_num
      assert_equal 2, @job_list_2.frequency_num
    end
    
    should "provide frequency interval" do
      assert_equal 'day', @job_list_1.frequency_interval
      assert_equal 'days', @job_list_2.frequency_interval
    end
  end
end
