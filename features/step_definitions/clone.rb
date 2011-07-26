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
  @result.id.should_not == @instance.id
  @result.title.should == @instance.title
end

Then /^that new instance should not be saved$/ do
  @result.new_record?.should be(true)
end

Then /^that new instance should be saved$/ do
  @result.new_record?.should be(false)
end

Given /^a published document that includes CouchCloner$/ do
  unless defined? PublishableDocument
    class PublishableDocument < CouchRest::Model::Base
      include CouchPublish
      include CouchCloner

      property :title
    end
  end

  @instance = PublishableDocument.create :title => "awesome publishable document"
  @instance.title = "awesome publishable document v2"
  @instance.publish!
end

Then /^I should not receive the versions from the original instance$/ do
  @instance.versions.count.should == 2
  @instance.published?.should be(true)
  @result.versions.count.should == 1
  @result.published?.should be(false)
end

Then /^my new instance should have (\d+) versions$/ do |num_versions|
  @result.versions.count.should == num_versions.to_i
end
