unless defined? QueryModel
  class QueryModel < CouchRest::Model::Base
    include CouchCloner
  end
end

Given /^(\d+) QueryModel document clones with clone_id "([^"]*)"$/ do |num, clone_id|
  num.to_i.times { QueryModel.create :clone_id => clone_id }
end

When /^I call "([^"]*)"$/ do |code|
  @result = eval code
end

Then /^I should receive all of the "([^"]*)" clones$/ do |clone_id|
  @result.collect(&:clone_id).all? {|c| c == clone_id }.should be(true)
end

Then /^I should not receive any "([^"]*)" clones$/ do |clone_id|
  @result.collect(&:clone_id).any? {|c| c == clone_id }.should be(false)
end

Then /^I should receive (\d+)$/ do |num|
  @result.should == num.to_i
end

Given /^several QueryModel documents with clone_id "([^"]*)" scheduled in the past and the future$/ do |clone_id|
  @past = QueryModel.create :clone_id => clone_id, :start => 2.days.ago
  @future = QueryModel.create :clone_id => clone_id, :start => 2.days.from_now
end

Given /^several QueryModel documents with clone_id "([^"]*)" without a start time$/ do |clone_id|
  @second_infinity = QueryModel.create :clone_id => clone_id
  Timecop.freeze(10.days.ago) do
    @first_infinity = QueryModel.create :clone_id => clone_id
  end
end

Then /^they should be ordered by their `start` property$/ do
  @result.length.should == 4
  @result[0].id.should == @past.id
  @result[1].id.should == @future.id
end

Then /^the documents without a start property should be sorted at the end by their `created_at` timestamp$/ do
  @result[2].id.should == @first_infinity.id
  @result[3].id.should == @second_infinity.id
end

Given /^(\d+) QueryModel documents with clone_id "([^"]*)" scheduled in the past$/ do |num, clone_id|
  num.to_i.downto(1) do |i|
    QueryModel.create :clone_id => clone_id, :start => i.days.ago
  end
end

Given /^(\d+) QueryModel documents with clone_id "([^"]*)" scheduled in the future$/ do |num, clone_id|
  num.to_i.downto(1) do |i|
    QueryModel.create :clone_id => clone_id, :start => i.days.from_now
  end
end

Given /^1 QueryModel document with clone_id "([^"]*)" scheduled in the past$/ do |clone_id|
  @active = QueryModel.create :clone_id => clone_id, :start => 1.day.ago
end

Then /^I should receive the QueryModel document with clone_id "([^"]*)" scheduled in the past$/ do |clone_id|
  @result.should_not be(nil)
  @result.id.should == @active.id
end

Then /^I should receive nil$/ do
  @result.should be(nil)
end

Given /^1 QueryModel document with clone_id "([^"]*)" scheduled a week ago$/ do |clone_id| 
  @week_old = QueryModel.create :start => 1.week.ago, :clone_id => clone_id
end

Given /^1 QueryModel document with clone_id "([^"]*)" scheduled a day ago$/ do |clone_id|
  @active = QueryModel.create :start => 1.day.ago, :clone_id => clone_id
end

Then /^the first should be my QueryModel document with clone_id "([^"]*)" scheduled a day ago$/ do |clone_id|
  @result.first.id.should == @active.id
end

Then /^that should be followed by my (\d+) QueryModel documents with clone_id "([^"]*)" scheduled in the future$/ do |num, clone_id|
  @result[1..num.to_i].collect(&:start).all? {|s| s > Time.now }.should be(true)
end

Then /^I should not receive my QueryModel document with clone_id "([^"]*)" scheduled a week ago$/ do |arg1|
  @result.collect(&:id).any? {|id| id == @week_old.id}.should be(false)
end

Then /^I should not receive any QueryModel documents without clone_id "([^"]*)"$/ do |clone_id|
  @result[1..-1].collect(&:clone_id).all? {|c| c == clone_id}.should be(true)
end

Then /^that should be followed by my (\d+) QueryModel documents that have no start time$/ do |arg1|
  @result[3..-1].collect(&:start).all? {|t| t == nil}.should be(true)
end

Given /^(\d+) QueryModel documents with clone_id "([^"]*)" scheduled over a week ago$/ do |num, clone_id|
  @weeks_old = []
  num.to_i.downto(1) {|i| @weeks_old << QueryModel.create(:clone_id => clone_id, :start => i.weeks.ago) }
end

Then /^I should receive only my (\d+) QueryModel documents with clone_id "([^"]*)" scheduled over a week ago$/ do |arg1, arg2|
  @result.collect(&:id).sort.should == @weeks_old.collect(&:id).sort
end

Given /^I have QueryModel documents with clone_id "([^"]*)"$/ do |clone_id|
  2.times { QueryModel.create :clone_id => clone_id }
end

Then /^I should receive an array "([^"]*)"$/ do |array|
  eval(array).should == @result
end

Given /^I have (\d+) QueryModel documents with clone_id "([^"]*)"$/ do |num, clone_id|
  num.to_i.times { QueryModel.create :clone_id => clone_id }
end
