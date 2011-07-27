Feature: Scheduling
  As a content publisher
  I want to give my documents a start date
  So that I can schedule them for publishing

  Scenario: Providing a unique start time
    Given an instance of a document model that includes CouchCloner
    When I provide a unique "start" time to my instance
    Then I should be able to save that instance

  Scenario: Providing a non-unique start time to a clone
    Given an instance of a document model that includes CouchCloner
    When I provide a unique "start" time to my instance
    Then I should be able to save that instance
    When I clone that instance
    And I provide the same "start" time to the clone
    Then I should not be able to save the clone
