Given /^I have a model that includes .*:$/ do |string|
  eval string
end

Then /^my model should respond to.*:$/ do |string|
  eval string
end
