Given /^an instance of a document model that includes CouchCloner$/ do
  unless defined? Document
    class Document < CouchRest::Model::Base
      include CouchCloner
      property :title
    end
  end

  @instance = Document.create :title => "original"
end

When /^I call the "([^"]*)" method on the instance$/ do |method|
  @result = @instance.send method 
end

Then /^I should receive a new instance with all of the properties copied from the original instance$/ do
  @result.title.should == "original"
end

Then /^that new instance should not be saved$/ do
  @result.new_record?.should be(true)
end

Then /^that new instance should be saved$/ do
  @result.new_record?.should be(false)
end
