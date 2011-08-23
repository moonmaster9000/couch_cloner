## CouchCloner

Clone your CouchDB `CouchRest::Model::Base` documents and schedule them for publishing.


## Installation

It's a ruby gem called `couch_cloner`. Install it.


## Setup

Simply include the module `CouchCloner` into your `CouchRest::Model::Base` document. For example:

    class HtmlSnippet < CouchRest::Model::Base
      include CouchCloner
    end

Setup complete.


## Cloning (.clone/.clone!)

Let's imagine we'd like to create an HtmlSnippet that appears on the home page of our website. Our model definition might look like this:

    class HtmlSnippet < CouchRest::Model::Base
      include CouchCloner

      property :content

      timestamps!
    end

And our snippet might look like this:

    homepage = HtmlSnippet.create :clone_id => "homepage", :content => "<h1>Homepage!</h1>"

OK, so that's a pretty lame bit of content, but did you notice the `clone_id`? If you're going to clone, you have to set a `clone_id` on your document first. The `clone_id` is the shared identifier between all of your clones. That's important; you'll see why in a few moments. Read on.

So now your content administrators want to use your CMS to schedule clones of this content to publish on the site several days in advance. How do we clone it? 

We can create a soft clone (i.e., a new HtmlSnippet based on the original, but not yet persisted to the database) via the `clone` method:

    next = homepage.clone

    next.content      #==> "<h1>Homepage!</h1>"
    next.clone_id     #==> "homepage"
    next.new_record?  #==> true

We can create a persisted clone with the `clone!` method:
    
    next = homepage.clone!

    next.content      #==> "<h1>Homepage!</h1>"
    next.clone_id     #==> "homepage"
    next.new_record?  #==> false

Note that, when cloned, the `start` scheduling property of the clone is not copied. See the next section for details about how scheduling works. 


## Scheduling (.start)

The utility of these clones is most apparent when you schedule multiple clones. The scheduling has only one constraint: each document in a clone group must have a unique date/time stamp, or `nil`.

Returning to our previous example of `next` and `homepage` HtmlSnippet clones:

    homepage.start = Time.now.beginning_of_day
    homepage.save #==> true

We've now scheduled the `original` clone to start at the beginning of today.

Next, we'll try to schedule the `next` clone for the same time:

    next.start = Time.now.beginning_of_day
    next.save #==> false
    next.errors[:start] #==> "must be unique"

Since we need to create a unique timestamp, we'll schedule `next` to start tomorrow:
    
    next.start = 1.day.from_now
    next.save #==> true
    next.errors.empty? #==> true

We could proceed creating and scheduling clones like this ad infinitum.


## Retrieving all the clones in a clone_id group (.map_by_clone_id/.count_by_clone_id)

To retrieve all of the clones with the same clone_id, call the `.map_by_clone_id` query proxy and provide it with a clone_id key that you want to look up:

    HtmlSnippet.map_by_clone_id.key("some_clone_id").get!

If you're unfamiliar with this syntax, read up on the `couch_view` gem at http://github.com/moonmaster9000/couch_view

This will return all clones with that clone_id. You can pass all of the usual map/reduce options to this method (e.g., limit/skip):
    
    HtmlSnippet.map_by_clone_id.key("some_clone_id").limit(10).skip(10).get!

Clones with the same clone_id will be sorted by their `_id` (this is simply how CouchDB works). 

A more useful sorting option is to have the documents sorted by their `start` property. Clones with a `start` of `nil` or `""` will sort last, and will order by their `created_at` property. Thus, it's as if the clones with a `start` time are assumed to be scheduled at time `infinity + created_at`. Pretty cool, right?

To get all the clones with the same `clone_id` sorted in this order, call `map_by_clone_id_and_start`:
    
    HtmlSnippet.map_by_clone_id_and_start("some_clone_id")

This will return a query proxy with a startkey of `["some_clone_id"]`, and an endkey of `["some_clone_id", {:end => true}]`, which will select all of the documents with clone id "some_clone_id", sorted by their "start" time.

You can pass off all of the usual map/reduce options to this view:
    
    HtmlSnippet.map_by_clone_id_and_start("some_clone_id").limit(10).skip(1).get!

If you'd like to retrieve only a subset of this view, you can use the `:key` map/reduce option. For example, suppose we'd like to see all clones scheduled to start after now:

    HtmlSnippet.map_by_clone_id_and_start("some_clone_id", Time.now)

The `endkey` will still be automatically defaulted to `["some_clone_id", {:end => nil}]`

Lastly, you can find the total number of clones with the same `clone_id` by calling the `count_by_clone_id` class method on your model:

    HtmlSnippet.count_by_clone_id("some_clone_id")

If you wanted to count only a subset of your clones based on their `start` time, you can use `count_by_clone_id_and_start`:

    HtmlSnippet.count_by_clone_id_and_start("some_clone_id", Time.now)

Again, the `endkey` will be automatically defaulted to `["some_clone_id", {:end => nil}]`


## Retrieving the active clone by clone_id (.map_active_by_clone_id)

Now that we've created an original clone scheduled today, and a `next` clone scheduled tomorrow, let's determine which one is currently active:

    HtmlSnippet.map_active_by_clone_id("homepage").get!.first.content #==> "<h1>this is awesome</h1>"

The `map_active_by_clone_id` method accepts a `clone_id` (in our case a `label`), and returns a query proxy that will return either zero or one results (zero if no currently active `HtmlSnippet` is found with that label, otherwise, one for the currently active `HtmlSnippet`).


## Retrieving clones scheduled into the future (.map_future_clones_by_clone_id)

We can get a list of the future clones by label via the `map_future_clones_by_clone_id` method:
    
    past = HtmlSnippet.create :clone_id => "homepage", :start => 1.day.ago
    next = HtmlSnippet.create :clone_id => "homepage", :start => 1.day.from_now

    HtmlSnippet.map_future_clones_by_clone_id("homepage").get!
      #==> returns the homepage snippet "next" that starts one day from now

This is essentially a shortcut for:
    
    HtmlSnippet.map_by_clone_id_and_start("homepage", Time.now)

If we create a clone with a `start` of `nil`, they will show up sorted at the end of `map_future_clones_by_clone_id`:

    future = next.clone! #==> remember, on clone, the `start` property is not copied
    future.start.should == nil
    future.save

    HtmlSnippet.map_future_clones_by_clone_id("homepage").get!
      #==> would return an array consisting of the `next` clone followed by the `future` clone

If there are multiple clones with a start of `nil`, they will sort by their `created_at` timestamp.

We also provide a method for counting the number of active and future clones in a given clone_id group:

    HtmlSnippet.count_future_clones_by_clone_id("some_clone_id").get!


## Retrieving past clones (.map_past_clones_by_clone_id)

You might find it useful to retrieve only the clones scheduled in the past. You can use the `map_past_clones_by_clone_id` method:

    HtmlSnippet.map_past_clones_by_clone_id("some_clone_id").get!

They will be ordered by their start date.

You can also count the number of past clones via the `count_past_clones_by_clone_id`:
    
    HtmlSnippet.count_past_clones_by_clone_id("some_clone_id").get!


## Retreiving the list of currently used clone_ids (.map_clone_ids)

You can retrieve an array of all of the `clone_id`'s in use by calling the `map_clone_ids` method on your model:

    HtmlSnippet.database.recreate!
    HtmlSnippet.create :clone_id => "homepage"
    HtmlSnippet.create :clone_id => "contact_us"
    HtmlSnippet.create :clone_id => "news"

    HtmlSnippet.map_clone_ids.get! 
      #==> ["contact_us", "homepage", "news"]

You can use all of the map/reduce options you're used to (e.g., limit/skip):

    HtmlSnippet.map_clone_ids.limit(1).skip(1).get! 
      #==> ["homepage"] 

You can also get a count of all clone_ids: 

    HtmlSnippet.count_clone_ids 
      #==> 3


## Retreiving the clone created farthest in the future for a clone_id group (.map_last_future_clone_by_clone_id)

If you'd like to retrieve the latest clone within a clone group, you could of course call `future_clones_by_clone_id` and then call `last` on the resulting array - however, that would be quite silly and idiotically inefficiant. So, instead, call `last_future_clone_by_clone_id`:

    snippet_1 = HtmlSnippet.create :clone_id => "snippety", :start => Time.now
    snippet_2 = HtmlSnippet.create :clone_id => "snippety", :start => 1000.years.from_now
    
    HtmlSnippet.map_last_future_clone_by_clone_id("snippety").get!.first.should == snippet_2

After creating these two snippet's, calling `HtmlSnippet.last_future_clone_by_clone_id "snippety"` would return `snippet_2`. However, if we create another "snippety" snippet without a `start` date:

    snippet_3 = HtmlSnippet.create :clone_id => "snippety"

    HtmlSnippet.map_last_future_clone_by_clone_id("snippety").get!.first.should == snippet_3

Then calling `HtmlSnippet.last_future_clone_by_clone_id "snippety"` would return `snippet3`. Basically, you can imagine clones with a null start date or an empty string start date to have a start scheduled for `infinity + created_at`; in other words, they sort at the end of the map of clones in a clone_id group, and if there are multiple clones without a start date, then they sort by created at (still at the end of the map). 


## CouchPublish Integration

The `couch_cloner` gem integrates nicely with the `couch_publish` gem.

If you include `CouchCloner` into a gem that already includes `CouchPublish`, then you can use `published` and `unpublished` query modifiers on your query proxies:
    
    class HtmlSnippet < CouchRest::Model::Base
      include CouchPublish
      include CouchCloner

      # etc...
    end
    
    HtmlSnippet.map_by_clone_id.key("some-clone-id").published.get!
    HtmlSnippet.count_by_clone_id.key("some-clone-id").unpublished.get!
    HtmlSnippet.map_active_by_clone_id("some-clone-id").published.get!.first
    HtmlSnippet.map_by_clone_id_and_start("some_clone_id")
    HtmlSnippet.map_active_and_future_clones_by_clone_id("some-clone-id").unpublished.get!.first
    HtmlSnippet.map_last_future_clone_by_clone_id("some-clone-id").published.get!.first
    HtmlSnippet.clone_ids.unpublished.get!
    HtmlSnippet.count_clone_ids.published.get!


## CouchVisible Integration

The `couch_cloner` gem integrates nicely with the `couch_visible` gem.

If you include `CouchCloner` into a gem that already includes `CouchVisible`, then you can pass `:shown => true` and `:hidden => true` options to your `CouchCloner` query methods:

    
    class HtmlSnippet < CouchRest::Model::Base
      include CouchVisible
      include CouchCloner

      # etc...
    end
    
    HtmlSnippet.map_by_clone_id.key("some-clone-id").shown.get!
    HtmlSnippet.count_by_clone_id.key("some-clone-id").hidden.get!
    HtmlSnippet.map_active_by_clone_id("some-clone-id").shown.get!.first
    HtmlSnippet.map_by_clone_id_and_start("some_clone_id")
    HtmlSnippet.map_active_and_future_clones_by_clone_id("some-clone-id").hidden.get!.first
    HtmlSnippet.map_last_future_clone_by_clone_id("some-clone-id").shown.get!.first
    HtmlSnippet.clone_ids.hidden.get!
    HtmlSnippet.count_clone_ids.shown.get!


## CouchPublish and CouchVisible Integration

If you include `CouchCloner` into a gem that already includes both `CouchVisible` and `CouchPublish`, then you can, of course, mix and match `unpublished`, `published`, `shown`,  and `hidden` query modifiers in your `CouchCloner` query methods: 
    
    class HtmlSnippet < CouchRest::Model::Base
      include CouchPublish
      include CouchVisible
      include CouchCloner

      # etc...
    end
    
    HtmlSnippet.map_by_clone_id.key("some-clone-id").shown.published.get!
    HtmlSnippet.count_by_clone_id.key("some-clone-id").hidden.get!
    HtmlSnippet.map_active_by_clone_id("some-clone-id").shown.get!.first
    HtmlSnippet.map_by_clone_id_and_start("some_clone_id")
    HtmlSnippet.map_active_and_future_clones_by_clone_id("some-clone-id").hidden.published.get!.first
    HtmlSnippet.map_last_future_clone_by_clone_id("some-clone-id").shown.get!.first
    HtmlSnippet.clone_ids.hidden.get!
    HtmlSnippet.count_clone_ids.shown.unpublished.get!

## PUBLIC DOMAIN

This software is public domain. By contributing to it, you agree to let your code contribution enter the public domain.
