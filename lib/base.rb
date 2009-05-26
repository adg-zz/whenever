module Whenever
  
  # Add more intervals here as we decide to support them for editing
  #
  # Intervals supported by Whenever::Output::Cron:
  # Times
  #   - minutes
  #   - hours
  #   - days
  #   - months
  # Symbols
  #   - :reboot
  #   - :year, :yearly
  #   - :day, :daily
  #   - :midnight
  #   - :month, :monthly
  #   - :week, :weekly
  #   - :hour, :hourly
  # Strings
  #   - sun, mon, tue, wed, thu, fri, sat
  #   - weekday
  #   - weekend
  def self.intervals
    %w(days months)
  end
  
  def self.cron(options)
    Whenever::JobList.new(options).generate_cron_output
  end
  
  def self.path
    if defined?(RAILS_ROOT)
      RAILS_ROOT 
    elsif defined?(::RAILS_ROOT)
      ::RAILS_ROOT
    end
  end
  
end