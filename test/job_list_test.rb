require 'rubygems'
require 'ruby-debug'

require File.expand_path(File.dirname(__FILE__) + "/test_helper")

class JobListTest < Test::Unit::TestCase

  context "A JobList for days-based jobs" do
    setup do
      @jobs = <<-JOBS
every 1.day do
  runner 'foo'
end

every 2.days, :at => '4:30am' do
  runner 'bar'
end
      JOBS
      
      @job_list = Whenever::JobList.new(:string => @jobs)
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
    
    context "with updated schedule" do
      setup do
        @filename = 'test/fixtures/schedule.rb'
        File.open(@filename, 'w') { |f| f.write(@jobs) }
        @task = 'bar'
        @schedule = {"interval"=>"days", "frequency"=>"4", "at"=>"10:00pm"}
        Whenever::JobList.new(:file => File.expand_path(@filename)).update_schedule_for_task(@task, @schedule)
        @job_list = Whenever::JobList.new(:file => File.expand_path(@filename))
      end
      
      should "provide updated scheduled job" do
        assert_equal 4, @job_list.schedule_data_for_task(@task)[:frequency]
        assert_equal '10:00pm', @job_list.schedule_data_for_task(@task)[:at]
      end
      
      should "update schedule file" do
        lines = File.readlines(@filename)
        lines.each_with_index do |line, i|
          if line.include?(@task)
            j = i - 1
            assert lines[j].include?('4.days')
            assert lines[j].include?('10:00pm')
          end
        end
      end
    end
  end
end
