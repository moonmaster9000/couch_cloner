Feature: Querying Clones
  As a programmer
  I want to be able to slice and dice my clones in all kinds of ways
  So that I can build useful interfaces around my data
  
  Scenario: Retrieving all the clones in a clone_id group (.map_by_clone_id)
    Given a Query model that includes CouchCloner:
      """
        class Query < CouchRest::Model::Base
          include CouchCloner
          timestamps!
        end
      """

    And 4 Query document clones with clone_id "clone_id_1":
      """
        @clone_id_1_clones = []
        4.times { @clone_id_1_clones << Query.create(:clone_id => "clone_id_1") }
      """

    And 3 Query document clones with clone_id "clone_id_2":
      """
        @clone_id_2_clones = []
        3.times { @clone_id_2_clones << Query.create(:clone_id => "clone_id_2") }
      """

    Then `Query.map_by_clone_id.key("clone_id_1").get!` should return all of the clone_id_1 clones:
      """
        Query.map_by_clone_id.key("clone_id_1").get!.collect(&:id).sort.should == @clone_id_1_clones.collect(&:id).sort 
      """


  Scenario: Counting all the clones in a clone_id group (.count_by_clone_id)
    Given a Query model that includes CouchCloner:
      """
        class Query < CouchRest::Model::Base
          include CouchCloner
          timestamps!
        end
      """

    And 4 Query document clones with clone_id "clone_id_1":
      """
        @clone_id_1_clones = []
        4.times { @clone_id_1_clones << Query.create(:clone_id => "clone_id_1") }
      """

    And 3 Query document clones with clone_id "clone_id_2":
      """
        @clone_id_2_clones = []
        3.times { @clone_id_2_clones << Query.create(:clone_id => "clone_id_2") }
      """

    Then `Query.count_by_clone_id.key("clone_id_1").get!` should return 4:
      """
        Query.count_by_clone_id.key("clone_id_1").get!.should == 4 
      """

    And `Query.count_by_clone_id.key("clone_id_2").get!` should return 3:
      """
        Query.count_by_clone_id.key("clone_id_2").get!.should == 3 
      """


  Scenario: Retrieving all the clones in a clone_id group ordered by `start` (.map_by_clone_id_and_start)
    Given a Query model that includes CouchCloner:
      """
        class Query < CouchRest::Model::Base
          include CouchCloner
          timestamps!
        end
      """

    And several Query documents with clone_id "clone_id_1" scheduled in the past and the future:
      """
        @clones = []
        @future = Query.create(:clone_id => "clone_id_1", :start => 1.day.from_now)
        @past   = Query.create(:clone_id => "clone_id_1", :start => 1.day.ago)
        @clones << @future << @past
      """

    And several Query documents with clone_id "clone_id_1" without a start time:
      """
        Timecop.freeze 1.day.from_now
        @unscheduled_2 = Query.create(:clone_id => "clone_id_1")
        Timecop.return
        @unscheduled_1 = Query.create(:clone_id => "clone_id_1")
        @clones << @unscheduled_2 << @unscheduled_1
      """

    Then "Query.map_by_clone_id_and_start('clone_id_1').get!" should return all of the "clone_id_1" clones:
      """
        @result = Query.map_by_clone_id_and_start('clone_id_1').get!
        @result.collect(&:id).sort.should == @clones.collect(&:id).sort
      """

    And they should be ordered by their `start` property:
      """
        @result[0].id.should == @past.id
        @result[1].id.should == @future.id
      """

    And the documents without a start property should be sorted at the end by their `created_at` timestamp:
      """
        @result[2].id.should == @unscheduled_1.id
        @result[3].id.should == @unscheduled_2.id
      """


  Scenario: Counting a subset of the clones in a clone_id group ordered by `start` (.count_by_clone_id_and_start)
    Given a Query model that includes CouchCloner:
      """
        class Query < CouchRest::Model::Base
          include CouchCloner
          timestamps!
        end
      """

    And two Query documents with clone_id "clone_id_1" scheduled in the past and the future:
      """
        @clones = []
        @future = Query.create(:clone_id => "clone_id_1", :start => 1.day.from_now)
        @past   = Query.create(:clone_id => "clone_id_1", :start => 1.day.ago)
        @clones << @future << @past
      """

    And two Query documents with clone_id "clone_id_1" without a start time:
      """
        Timecop.freeze 1.day.from_now
        @unscheduled_2 = Query.create(:clone_id => "clone_id_1")
        Timecop.return
        @unscheduled_1 = Query.create(:clone_id => "clone_id_1")
        @clones << @unscheduled_2 << @unscheduled_1
      """

    Then "Query.count_by_clone_id_and_start('clone_id_1').get!" should return 4:
      """
        Query.count_by_clone_id_and_start('clone_id_1').get!.should == 4
      """


  Scenario: Retrieving the active clone within a clone_id group (.map_active_by_clone_id) 
    Given a Query model that includes CouchCloner:
      """
        class Query < CouchRest::Model::Base
          include CouchCloner
          timestamps!
        end
      """
      
      And 1 Query document with clone_id "clone_id_1" scheduled in the past:
        """
          @past = Query.create :clone_id => "clone_id_1", :start => 1.day.ago
        """

      And 2 Query documents with clone_id "clone_id_1" scheduled in the future:
        """
          Query.create :clone_id => "clone_id_1", :start => 1.day.from_now
          Query.create :clone_id => "clone_id_1", :start => 2.days.from_now
        """

      And 5 Query documents with clone_id "clone_id_1":
        """
          5.times { Query.create :clone_id => "clone_id_1" }     
        """

      And 1 Query document with clone_id "clone_id_0" scheduled in the past:
        """
          Query.create :clone_id => "clone_id_0", :start => 3.days.ago
        """

      And 9 Query documents with clone_id "clone_id_2" scheduled in the future:
        """
          9.times { Query.create :clone_id => "clone_id_2" }
        """
    
    Then "QueryModel.map_active_by_clone_id('clone_id_1').get!.first" should return the clone "clone_id_1" scheduled in the past:
      """
        Query.map_active_by_clone_id('clone_id_1').get!.first.id.should == @past.id
      """
    
    And "QueryModel.map_active_by_clone_id('clone_id_2').get!" should return an empty result set:
      """
        Query.map_active_by_clone_id('clone_id_2').get!.should == []
      """

    And "QueryModel.map_active_by_clone_id('unknown').get!" should return an empty result set:
      """
        Query.map_active_by_clone_id('unknown').get!.should == []
      """


  Scenario: Retrieving clones scheduled now into the future (.map_future_by_clone_id)
    Given a Query model that includes CouchCloner:
      """
        class Query < CouchRest::Model::Base
          include CouchCloner
          timestamps!
        end
      """

      And 1 Query document with clone_id "clone_id_1" scheduled a week ago:
        """
          @week_ago = Query.create :clone_id => "clone_id_1", :start => 1.week.ago
        """

      And 1 Query document with clone_id "clone_id_1" scheduled a day ago:
        """
          @day_ago = Query.create :clone_id => "clone_id_1", :start => 1.day.ago
        """

      And 2 Query documents with clone_id "clone_id_1" scheduled in the future:
        """
          @future = []
          @future << Query.create(:clone_id => "clone_id_1", :start => 1.day.from_now)
          @future << Query.create(:clone_id => "clone_id_1", :start => 2.days.from_now)
        """

      And 5 Query document clones with clone_id "clone_id_1":
        """
          (1..5).each do |i| 
            Timecop.freeze i.to_i.days.from_now
            @future << Query.create(:clone_id => "clone_id_1")
            Timecop.return
          end
        """
      And 9 Query documents with clone_id "clone_id_2" scheduled in the future:
        """
          (1..9).each { |i| Query.create :clone_id => "clone_id_2", :start => i.to_i.days.from_now }
        """
    
    Then "Query.map_future_by_clone_id('clone_id_1').get!" should return the "clone_id_1" documents scheduled into the future:
      """
        Query.map_future_by_clone_id('clone_id_1').get!.collect(&:id).should == @future.collect(&:id)
      """


  Scenario: Counting clones scheduled now into the future (.count_active_and_future_clones_by_clone_id)
    Given a Query model that includes CouchCloner:
      """
        class Query < CouchRest::Model::Base
          include CouchCloner
          timestamps!
        end
      """

      And 1 Query document with clone_id "clone_id_1" scheduled a week ago:
        """
          @week_ago = Query.create :clone_id => "clone_id_1", :start => 1.week.ago
        """

      And 1 Query document with clone_id "clone_id_1" scheduled a day ago:
        """
          @day_ago = Query.create :clone_id => "clone_id_1", :start => 1.day.ago
        """

      And 2 Query documents with clone_id "clone_id_1" scheduled in the future:
        """
          @future = []
          @future << Query.create(:clone_id => "clone_id_1", :start => 1.day.from_now)
          @future << Query.create(:clone_id => "clone_id_1", :start => 2.days.from_now)
        """

      And 5 Query document clones with clone_id "clone_id_1":
        """
          (1..5).each do |i| 
            Timecop.freeze i.to_i.days.from_now
            @future << Query.create(:clone_id => "clone_id_1")
            Timecop.return
          end
        """
      And 9 Query documents with clone_id "clone_id_2" scheduled in the future:
        """
          (1..9).each { |i| Query.create :clone_id => "clone_id_2", :start => i.to_i.days.from_now }
        """
    
    Then "Query.count_future_by_clone_id('clone_id_1').get!" should return 7:
      """
        Query.count_future_by_clone_id('clone_id_1').get!.should == 7
      """

  
  Scenario: Retrieving past clones (.map_past_by_clone_id)
    Given a Query model that includes CouchCloner:
      """
        class Query < CouchRest::Model::Base
          include CouchCloner
          timestamps!
        end
      """

      And 1 Query document with clone_id "clone_id_1" scheduled a week ago:
        """
          @week_ago = Query.create :clone_id => "clone_id_1", :start => 1.week.ago
        """

      And 1 Query document with clone_id "clone_id_1" scheduled a day ago:
        """
          @day_ago = Query.create :clone_id => "clone_id_1", :start => 1.day.ago
        """

      And 2 Query documents with clone_id "clone_id_1" scheduled in the future:
        """
          @future = []
          @future << Query.create(:clone_id => "clone_id_1", :start => 1.day.from_now)
          @future << Query.create(:clone_id => "clone_id_1", :start => 2.days.from_now)
        """

      And 5 Query document clones with clone_id "clone_id_1":
        """
          (1..5).each do |i| 
            Timecop.freeze i.to_i.days.from_now
            @future << Query.create(:clone_id => "clone_id_1")
            Timecop.return
          end
        """
      And 9 Query documents with clone_id "clone_id_2" scheduled in the future:
        """
          (1..9).each { |i| Query.create :clone_id => "clone_id_2", :start => i.to_i.days.from_now }
        """
    
    Then "Query.map_past_by_clone_id('clone_id_1').get!" should return the "clone_id_1" documents scheduled in the past:
      """
        Query.map_past_by_clone_id('clone_id_1').get!.collect(&:id).should == [@day_ago, @week_ago].collect(&:id)
      """


  Scenario: Counting past clones (.past_clones_by_clone_id)
    Given a Query model that includes CouchCloner:
      """
        class Query < CouchRest::Model::Base
          include CouchCloner
          timestamps!
        end
      """

      And 1 Query document with clone_id "clone_id_1" scheduled a week ago:
        """
          @week_ago = Query.create :clone_id => "clone_id_1", :start => 1.week.ago
        """

      And 1 Query document with clone_id "clone_id_1" scheduled a day ago:
        """
          @day_ago = Query.create :clone_id => "clone_id_1", :start => 1.day.ago
        """

      And 2 Query documents with clone_id "clone_id_1" scheduled in the future:
        """
          @future = []
          @future << Query.create(:clone_id => "clone_id_1", :start => 1.day.from_now)
          @future << Query.create(:clone_id => "clone_id_1", :start => 2.days.from_now)
        """

      And 5 Query document clones with clone_id "clone_id_1":
        """
          (1..5).each do |i| 
            Timecop.freeze i.to_i.days.from_now
            @future << Query.create(:clone_id => "clone_id_1")
            Timecop.return
          end
        """
      And 9 Query documents with clone_id "clone_id_2" scheduled in the future:
        """
          (1..9).each { |i| Query.create :clone_id => "clone_id_2", :start => i.to_i.days.from_now }
        """
    
    Then "Query.count_past_by_clone_id('clone_id_1').get!" should return 2:
      """
        Query.count_past_by_clone_id('clone_id_1').get!.should == 2
      """

 
    Then "Query.count_past_by_clone_id('clone_id_2').get!" should return 0:
      """
        Query.count_past_by_clone_id('clone_id_2').get!.should == 0
      """

    Then "Query.count_past_by_clone_id('unknown').get!" should return 0:
      """
        Query.count_past_by_clone_id('unknown').get!.should == 0
      """


  @focus
  Scenario: Retrieving the list of currently used clone_ids (.clone_ids)
    Given a Query model that includes CouchCloner:
      """
        class Query < CouchRest::Model::Base
          include CouchCloner
          timestamps!
        end
      """

    Given I have Query documents with clone_id "a":
      """
        2.times { Query.create :clone_id => "a" }
      """

    And I have Query documents with clone_id "b":
      """
        2.times {Query.create :clone_id => "b"}
      """

    And I have Query documents with clone_id "c":
      """
        2.times { Query.create :clone_id => "c" }
      """
    
    Then "Query.map_clone_ids.get!['rows'].map {|row| row['key']}" should return "['a', 'b', 'c']":
      """
        Query.map_clone_ids.get!['rows'].map {|row| row['key']}.should == ['a', 'b', 'c']
      """

    Then "Query.map_clone_ids.limit(2).get!['rows'].map {|row| row['key']}" should return "['a', 'b']":
      """
        Query.map_clone_ids.limit(2).get!['rows'].map {|row| row['key']}.should == ['a', 'b']
      """
    
    Then "Query.map_clone_ids.startkey('b').get!['rows'].map {|row| row['key']}" should return "['b', 'c']":
      """
        Query.map_clone_ids.startkey('b').get!['rows'].map {|row| row['key']}.should == ['b', 'c']
      """
 

  @focus
  Scenario: Counting all clone ids (.count_clone_ids!)
    Given a Query model that includes CouchCloner:
      """
        class Query < CouchRest::Model::Base
          include CouchCloner
          timestamps!
        end
      """

    Given I have Query documents with clone_id "a":
      """
        2.times { Query.create :clone_id => "a" }
      """

    And I have Query documents with clone_id "b":
      """
        2.times {Query.create :clone_id => "b"}
      """

    And I have Query documents with clone_id "c":
      """
        2.times { Query.create :clone_id => "c" }
      """
    
    Then "Query.count_clone_ids!" should return 3:
      """
        Query.count_clone_ids!.should == 3
      """


  @focus
  Scenario: Retrieve the clone created farthest in the future for a clone_id group (.last_future_by_clone_id)
    Given a Query model that includes CouchCloner:
      """
        class Query < CouchRest::Model::Base
          include CouchCloner
          timestamps!
        end
      """

    And several Query documents with clone_id "clone_id_1" scheduled in the past and the future:
      """
        @clones = []
        @future = Query.create(:clone_id => "clone_id_1", :start => 1.day.from_now)
        @past   = Query.create(:clone_id => "clone_id_1", :start => 1.day.ago)
        @clones << @future << @past
      """
    
    Then "Query.map_last_future_by_clone_id('clone_id_1')" should return the clone scheduled a day from now:
      """
        result = Query.map_last_future_by_clone_id('clone_id_1').get!
        result.length.should == 1
        result.first.id.should == @future.id
      """


    When I create a Query document with clone_id "clone_id_1" without a start time:
      """
        @unscheduled = Query.create(:clone_id => "clone_id_1")
      """

    Then "Query.last_future_by_clone_id('clone_id_1')" should return the clone scheduled a day from now:
      """
        result = Query.map_last_future_by_clone_id('clone_id_1').get!
        result.length.should == 1
        result.first.id.should == @unscheduled.id
      """

    Then "Query.last_future_by_clone_id('unknown')" should return an empty array:
      """
        Query.map_last_future_by_clone_id('unknown').get!.should == []
      """
