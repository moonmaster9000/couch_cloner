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
