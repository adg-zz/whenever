require File.expand_path(File.dirname(__FILE__) + "/test_helper")

class JobListTest < Test::Unit::TestCase

  context "A JobList for days-based jobs" do
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
    end

    should "have scheduled jobs" do
      assert_equal 2, @job_list.scheduled_jobs.size
    end
    
    should "have schedule for task" do
      assert_no_match /not found/, @job_list.schedule_for_task('foo')
      assert_no_match /not found/, @job_list.schedule_for_task('bar')
    end
    
    should "not have schedule for non-existent task" do
      assert_match /not found/, @job_list.schedule_for_task('baz')
    end
  end
end
