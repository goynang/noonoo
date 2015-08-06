require 'sinatra/base'

require_relative 'app/config'
require_relative 'app/helpers'
require_relative 'app/models'
require_relative 'app/routes'

module NooNoo
  class App < Sinatra::Application
  
    set :app_file, __FILE__
    
    helpers NooNoo::Helpers
    
    # If we have no pages then intialise the system (so is usable!)
    # Rather messy but will do for now...
    if NooNoo::Models::Page.empty?
      NooNoo::Models::Page.create({
        path: '/',
        title: 'Welcome to this here thing',
        zones: {
          primary: [
            {
              name: "heading",
              content: "Get the admin panel open"
            }, {
              name: "text",
              content: "<p>Click the little thing hanging off the right hand edge of the page to get going.</p>"
            }, {
              name: "heading",
              content: "Terms used"
            }, {
              name: "subheading",
              content: "Page"
            }, {
              name: "text",
              content: "<p>A <em>page</em> is... um, a page. Simple. Pages have a <em>layout</em> that determines the <em>zones</em> in the page where you can place content <em>elements</em>.</p>"
            }, {
              name: "subheading",
              content: "Layout"
            }, {
              name: "text",
              content: "<p>A <em>layout</em> determines the <em>zones</em> a <em>page</em> has.</p>"
            }, {
              name: "subheading",
              content: "Zone"
            }, {
              name: "text",
              content: "<p>A <em>zone</em> is an area where you can place content <em>elements</em>. Zones are either tied to a <em>layout</em> (for sharing content across pages) or to indiviudal <em>pages</em>.</p>"
            }, {
              name: "subheading",
              content: "Element (aka component)"
            }, {
              name: "text",
              content: "<p>A content <em>element</em> is the basic building block that makes a <em>page</em> interesting. You scatter them around to build your <em>page</em> up.</p>"
            }
          ],
          secondary: []
        },
        columns: 1,
        depth: 1,
        label: 'Home',
        show_in_menus: true,
        show_on_sitemap: true,
        layout: NooNoo::Models::Layout.create({
          title: 'Default',
          zones: {
            nav:[{name: 'menu', depth: 1}],
            heading:[{name: 'page-title'}],
            foot:[]
          }
        })
      })
    end
    
  end
end

# Make irb more useful ($irb and then $require './app.rb')
include NooNoo::Models
