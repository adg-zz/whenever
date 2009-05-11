require File.expand_path(File.dirname(__FILE__) + "/test_helper")

class JobListTest < Test::Unit::TestCase
  
  context "A JobList" do
    setup do
      @scheduled_job_1 = <<-JOB1
        every 2.hours do
          runner 'foo'
        end
      JOB1
      
      @scheduled_job_2 = <<-JOB2
        every 1.day, :at => '4:30am' do
          runner 'bar'
        end
      JOB2
    end
    
    should_eventually "provide whenever syntax hours-based scheduled job" do
      schedule = Whenever::JobList.new(:string => @scheduled_job_1).schedule_for_task('foo')
      assert_match /every 2 hours/, schedule
    end
    
    should "provide whenever syntax day-based scheduled job" do
      schedule = Whenever::JobList.new(:string => @scheduled_job_2).schedule_for_task('bar')
      assert_match /every 1 day/, schedule
    end
  end
end
