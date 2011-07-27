When /^I provide a unique "([^"]*)" time to my instance$/ do |prop|
  @instance.send "#{prop}=", Time.now
end

Then /^I should be able to save that instance$/ do
  @instance.save.should be(true)
end

When /^I clone that instance$/ do
  @clone = @instance.clone
end

When /^I provide the same "([^"]*)" time to the clone$/ do |prop|
  @clone.send "#{prop}=", @instance.send(prop)
end

Then /^I should not be able to save the clone$/ do
  @clone.save.should be(false)
end
