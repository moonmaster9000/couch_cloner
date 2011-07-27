Given /^an instance of a document model that includes CouchCloner$/ do
  unless defined? Document
    class Document < CouchRest::Model::Base
      include CouchCloner
      property :title

    end
  end

  @instance = Document.create :title => "original", :clone_id => "original_document"
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

  @instance = PublishableDocument.create :title => "awesome publishable document", :clone_id => "publishable_document"
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

When /^I include CouchCloner into a document model$/ do
  unless defined? CouchClonerDocument
    class CouchClonerDocument < CouchRest::Model::Base
      include CouchCloner
    end
  end
end

Then /^a "([^"]*)" property should be created$/ do |property|
  CouchClonerDocument.properties.collect(&:name).include?("clone_id").should be(true)
end

Given /^an instance of a document model that includes CouchCloner but does not have a clone_id$/ do
  unless defined? NoCloneId
    class NoCloneId < CouchRest::Model::Base
      include CouchCloner
    end
  end

  @instance = NoCloneId.create
end

Then /^I should not be able to clone that instance$/ do
  proc { @instance.clone }.should raise_exception("You must specify a non-nil clone_id on your 'NoCloneId' instance before you can clone it.")
  proc { @instance.clone!}.should raise_exception("You must specify a non-nil clone_id on your 'NoCloneId' instance before you can clone it.")
end
