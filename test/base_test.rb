require File.expand_path(File.dirname(__FILE__) + "/test_helper")

# This is more of a spec than a test.
class BaseTest < Test::Unit::TestCase
  
  should "support intervals" do
    %w(days months).each do |interval|
      assert Whenever.intervals.include?(interval)
    end
  end
  
  # Whenever supports these as input, but adg-whenever does not (yet) support
  # them as output when editing the schedule file.
  should "not support intervals" do
    syms = [:reboot, :year, :yearly, :day, :daily, :midnight, :month, :monthly, :week, :weekly, :hour, :hourly]
    syms.each do |interval|
      assert !Whenever.intervals.include?(interval)
    end
    strs = %w(sun mon tue wed thu fri sat weekday weekend)
    strs.each do |interval|
      assert !Whenever.intervals.include?(interval)
    end
  end
  
end
