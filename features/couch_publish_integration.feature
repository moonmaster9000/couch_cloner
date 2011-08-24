Feature: Integrate with CouchPublish
  As a programmer
  I want the CouchCloner gem to integrate with CouchPublish
  So that I can filter my queries for published and unpublished documents

  Scenario: Including CouchPublish should generate views for published and unpublished clone documents
    Given I have a model that includes CouchPublish and CouchCloner:
      """
        class Query < CouchRest::Model::Base
          include CouchPublish
          include CouchCloner

          timestamps!
        end
      """

    Then my model should respond to "by_by_clone_id_published":
      """
        proc { Query.by_by_clone_id_published }.should_not raise_exception
      """

    And my model should respond to "by_by_clone_id_unpublished":
      """
        proc { Query.by_by_clone_id_unpublished }.should_not raise_exception
      """

    And my model should respond to "by_by_clone_id_and_start_time_published":
      """
        proc { Query.by_by_clone_id_and_start_time_published }.should_not raise_exception
      """

    And my model should respond to "by_by_clone_id_and_start_time_unpublished":
      """
        proc { Query.by_by_clone_id_and_start_time_unpublished }.should_not raise_exception
      """
