## CouchCloner

Clone your CouchDB `CouchRest::Model::Base` documents and schedule them for publishing.

## Installation

It's a ruby gem called `couch_cloner`. Install it.

## Setup

Simply include the module `CouchCloner` into your `CouchRest::Model::Base` document. For example:

    class HtmlSnippet < CouchRest::Model::Base
      include CouchCloner
    end

Next, you need to define the shared identifier between all of your clones. Later, you'll look up clones by this identifier. I recommend using something human readable, like a url label:

    class HtmlSnippet < CouchRest::Model::Base
      include CouchCloner

      clone_id :label

      property :label
      property :content

      validates_presence_of :label
    end

Setup complete.

## Cloning

Let's imagine we've created an HtmlSnippet that appears on the home page of our website. Your content administrators want to use your CMS to schedule clones of this content to publish on the site several days in advance. How do we clone it? 

We can create a soft clone (i.e., a new HtmlSnippet based on the original, but not yet persisted to the database) via the `clone` method:

    original  = HtmlSnippet.create :content => "<h1>this is awesome</h1>", :label => "homepage_snippet"
    
    next      = original.clone

    next.content      #==> "<h1>this is awesome</h1>"
    next.label        #==> "homepage_snippet"
    next.new_record?  #==> true

We can create a persisted clone with the `clone!` method:
    
    next      = original.clone!

    next.content      #==> "<h1>this is awesome</h1>"
    next.label        #==> "homepage_snippet"
    next.new_record?  #==> false

## Scheduling

## PUBLIC DOMAIN

This software is public domain. By contributing to it, you agree to let your code contribution enter the public domain.
