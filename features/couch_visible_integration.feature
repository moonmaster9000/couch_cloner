Feature: Integrate with CouchVisible
  As a programmer
  I want the CouchCloner gem to integrate with CouchVisible
  So that I can filter my queries for shown and hidden documents

  Scenario: Including CouchVisible should generate views for shown and hidden clone documents
    Given I have a model that includes CouchVisible and CouchCloner:
      """
        class Query < CouchRest::Model::Base
          include CouchVisible
          include CouchCloner

          timestamps!
        end
      """

    Then my model should respond to "by_by_clone_id_shown":
      """
        proc { Query.by_by_clone_id_shown }.should_not raise_exception
      """

    And my model should respond to "by_by_clone_id_hidden":
      """
        proc { Query.by_by_clone_id_hidden }.should_not raise_exception
      """

    And my model should respond to "by_by_clone_id_and_start_time_shown":
      """
        proc { Query.by_by_clone_id_and_start_time_shown }.should_not raise_exception
      """

    And my model should respond to "by_by_clone_id_and_start_time_hidden":
      """
        proc { Query.by_by_clone_id_and_start_time_hidden }.should_not raise_exception
      """
