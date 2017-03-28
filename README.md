noonoo
======

Adventures in Ruby, Sinatra, <del>CouchDB</del> Mongo, Redis, Web Sockets, Javascript, HTML5 Microdata, and JSON.

A little web site editor (don't you dare say CMS) based on pages, components, templates, and maybe some other stuff in time.

Small, elegant, and surprisingly powerful.

Watch it in action
------------------

[Watch a screencast of a very early version in action](https://www.youtube.com/watch?v=jb8t4iftvaM)

Some piccies
------------

<img src="screenie1.png" width="100%" style="max-width: 100%;" />

<img src="screenie2.png" width="100%" style="max-width: 100%;" />

Getting started (untested instructions!)
----------------------------------------

First off you will need Ruby (and a relatively new version thereof). 

Use bundler to get the necessary dependencies...

        $ bundle install

You'll also need Mongo installed and running. This is configured via config/mongoid.yml. Start it up via the usual...

        $ mongod

Redis as well...

        $ redis-server 

Then to start up the app use foreman (which will fire the Unicorn server up)...

        $ foreman start

If everything is working you should now be able to see it at http://0.0.0.0:5000

Everything is Heroku friendly (assuming you have mongo and redis enabled).

The masterplan
--------------

* Editable templates (master pages)
* Drag and drop components onto pages or templates (and around them to reorganise)
* Inline editing comnbined with an inspector for the non-visual stuff
* Inter-component communication (e.g. a filter component determining what shows in a separate list component)
* Use pre-set collections of components and pages for common use cases (vertical apps)
* Web sockets for collobrative editing (instant update for all editors)
* Themeable
* Mobile preview (etc.) from within editing interface
* Super easy to use 
* Simple workflow support (draft, publish, etc.)
* Revision history, multiple undo, etc.
* Integration with CRMs etc. via prebuilt components

Tools, libraries, and what not to think about using
---------------------------------------------------

* WebComponents (standard stuff rather than custom stuff)?
* Native JS to replace jQuery where possible (or maybe zepto.js?) - what about jQueryUI?
* React? Vue? Angular?

TODOs
-----

* Stick to consitent name for elements (or components?)
* Swap in nicer templating (logic-less as possible)
* Work out how to store non-visual data with an element (stuff not exposed into HTML)
* Improve element inspecting (so can deal with nested HTML/attributes)
* Allow saving and re-application of custom user generated layouts (templates?)
* Inter-element communication (some kind of shared scope thing?) - classic e.g. filter and list
* Caching?!? How (for e.g.) avoid going to CRM API on every page load?
* How allow elements to do more than just display content? How allow input? e.g. update user details form
* Allow env settings for DB config etc.

Woe
---

Need a much better way of wiring interface elements that allow you to change the state of the page to the things that are affected by them. Otherwise it will become a big jumble of jQuery selectors to keep everything in sync - if it isn't already. Is there way react.js could help (or something similar)?
















Component
    server side
        persist state
        load state
        render
        publish state changes (to listening clients)
    client side
        instantiate
        render (AJAX proxy to server render OR client side template stuff?)
        handle inspector based state changes
        trigger persist state
        subscribe to state changes (from server side)
        
        
        
Client change <-> Server <-> Other clients


Inspector -> re-render (client or server side?) -> component 
Component -> save state (server side) -> update inspector


Local data proxy for state (push to server to publish changes?)







THOUGHTS...

Component DIR structure

my-great-component
    model.rb
    view.erb
    model.js
    inspect.erb
    

model.rb

module NooNoo
  module Components
    class Menu
      def self.render
          ...
          {page: page, component: component, xxx: yyyy}
      end
    end
  end
end

view.erb

<div data-prop-foo="<%= xxx.some_prop %>" itemprop="content"><%= xxx.content %></div>

implied data model

foo=
content=

Need to update JS page serialiser to allow for data-prop-* attributes.

Make it only serialise data-prop-* and itemprop values. Whitelist!

Global XHR route to allow server side rendering of components for injection into page

1. Change inspector value
2. Pass arguments to server (data-props and itemprops)
3. Save state in database (patch the page document)
4. Get HTML fragment back
5. Inject into page replacing original

Maybe defer page saves until push big "publish changes" button (so can work in draft?).

How about something like "submit changes" as well for pushing through workflow?

How deal with people not pushing one of those buttons and just (accidently?) leaving page (nag alert?)?

Will XHR be quick enough on inspector change (or too many XHRs if several fields in inspector)?

Can a component state if needs server side render and only use client side when safe to do so?

When OK to relay on "update" button rather than real time rendering?
