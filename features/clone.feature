Feature: Clone
  As a programmer
  I want the ability to clone documents
  So that I can create an army of document clones that will take over the world

  @focus
  Scenario: Soft clone (.clone)
    Given an instance of a document model that includes CouchCloner
    When I call the "clone" method on the instance
    Then I should receive a new instance with all of the properties copied from the original instance
    And that new instance should not be saved

  @focus
  Scenario: Persisted clone (.clone!)
    Given an instance of a document model that includes CouchCloner
    When I call the "clone!" method on the instance
    Then I should receive a new instance with all of the properties copied from the original instance
    And that new instance should be saved
