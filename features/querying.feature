Feature: Querying Clones
  As a programmer
  I want to be able to slice and dice my clones in all kinds of ways
  So that I can build useful interfaces around my data

  Scenario: Retrieving all the clones in a clone_id group (.by_clone_id)
    Given 4 QueryModel document clones with clone_id "clone_id_1"
    And   3 QueryModel document clones with clone_id "clone_id_2"
    When  I call "QueryModel.by_clone_id :key => 'clone_id_1'"
    Then  I should receive all of the "clone_id_1" clones
    And   I should not receive any "clone_id_2" clones

  Scenario: Counting all the clones in a clone_id group (.count_by_clone_id)
    Given 4 QueryModel document clones with clone_id "clone_id_1"
    And   3 QueryModel document clones with clone_id "clone_id_2"
    When  I call "QueryModel.count_by_clone_id :key => 'clone_id_1'"
    Then  I should receive 4
    When  I call "QueryModel.count_by_clone_id :key => 'clone_id_2'"
    Then  I should receive 3

  Scenario: Retrieving all the clones in a clone_id group ordered by `start` (.by_clone_id_and_start)
    Given several QueryModel documents with clone_id "clone_id_1" scheduled in the past and the future
    And several QueryModel documents with clone_id "clone_id_1" without a start time
    When  I call "QueryModel.by_clone_id_and_start 'clone_id_1'"
    Then  I should receive all of the "clone_id_1" clones
    And they should be ordered by their `start` property
    And the documents without a start property should be sorted at the end by their `created_at` timestamp

  Scenario: Counting a subset of the clones in a clone_id group ordered by `start` (.count_by_clone_id_and_start)
    Given 5 QueryModel documents with clone_id "clone_id_1" scheduled in the past
    And   3 QueryModel documents with clone_id "clone_id_1" scheduled in the future
    And   2 QueryModel document clones with clone_id "clone_id_2"
    When I call "QueryModel.count_by_clone_id_and_start 'clone_id_1'"
    Then I should receive 8
    When I call "QueryModel.count_by_clone_id_and_start :startkey => ['clone_id_1', Time.now]"
    Then I should receive 3

  @focus
  Scenario: Retrieving the active clone within a clone_id group (.active_by_clone_id) 
    Given 1 QueryModel document with clone_id "clone_id_1" scheduled in the past
    And   2 QueryModel documents with clone_id "clone_id_1" scheduled in the future
    And   5 QueryModel document clones with clone_id "clone_id_1"
    And   9 QueryModel documents with clone_id "clone_id_2" scheduled in the past
    When I call "QueryModel.active_by_clone_id 'clone_id_1'"
    Then I should receive the QueryModel document with clone_id "clone_id_1" scheduled in the past
