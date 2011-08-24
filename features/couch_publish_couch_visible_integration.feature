Feature: CouchPublish/CouchVisible Integration
  When both CouchPublish and CouchVisible are included into a model that includes CouchCloner
  Then I should be able to slice and dice my couch_cloner calls with "hidden", "show", "published", "unpublished" 

  Scenario: CouchPublish and CouchVisible Integration
    Given I have a model that includes CouchPublish, CouchVisible, and CouchCloner:
      """
        class Query < CouchRest::Model::Base
          include CouchPublish
          include CouchVisible
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

    Then my model should respond to "by_by_clone_id_published_shown":
      """
        proc { Query.by_by_clone_id_published_shown }.should_not raise_exception
      """
    
    Then my model should respond to "by_by_clone_id_shown_unpublished":
      """
        proc { Query.by_by_clone_id_shown_unpublished }.should_not raise_exception
      """

    And my model should respond to "by_by_clone_id_hidden_published":
      """
        proc { Query.by_by_clone_id_hidden_published }.should_not raise_exception
      """

    And my model should respond to "by_by_clone_id_hidden_unpublished":
      """
        proc { Query.by_by_clone_id_hidden_unpublished }.should_not raise_exception
      """

    And my model should respond to "by_by_clone_id_and_start_time_published_shown":
      """
        proc { Query.by_by_clone_id_and_start_time_published_shown }.should_not raise_exception
      """

    And my model should respond to "by_by_clone_id_and_start_time_hidden_published":
      """
        proc { Query.by_by_clone_id_and_start_time_hidden_published }.should_not raise_exception
      """

    And my model should respond to "by_by_clone_id_and_start_time_shown_unpublished":
      """
        proc { Query.by_by_clone_id_and_start_time_shown_unpublished }.should_not raise_exception
      """

    And my model should respond to "by_by_clone_id_and_start_time_hidden_unpublished":
      """
        proc { Query.by_by_clone_id_and_start_time_hidden_unpublished }.should_not raise_exception
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
