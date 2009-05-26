every 1.day do
  runner 'foo'
end

every 4.days, :at => '10:00pm' do
  runner 'bar'
end
