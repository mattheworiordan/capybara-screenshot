capybara-screenshot gem
=======================

Using this gem, whenever a [Capybara](https://github.com/jnicklas/capybara) test in [Cucumber](http://cukes.info/), [Rspec](https://www.relishapp.com/rspec) or Minitest  fails, the HTML for the failed page and a screenshot (when using [capybara-webkit](https://github.com/thoughtbot/capybara-webkit), [Selenium](http://seleniumhq.org/) or [poltergeist](https://github.com/jonleighton/poltergeist)) is saved into $APPLICATION_ROOT/tmp/capybara.

This is a huge help when trying to diagnose a problem in your failing steps as you can view the source code and potentially how the page looked at the time of the failure.

Usage
-----

    gem install capybara-screenshot

or update your Gemfile to include capybara-screenshot at the bottom (as of Bundler 0.10):

    group :test do
      gem 'capybara-screenshot'
    end

That's it!

If you require more control, you can generate the screenshot on demand rather than on failure. This is useful
if the failure occurs at a point where the screen shot is not as useful for debugging a rendering problem.

In Cucumber,

	screen_shot_and_save_page

Or for screenshot only, with image automatically opened

	screen_shot_and_open_image

Or anywhere, including specs and tests

	Capybara::Screenshot.screen_shot_and_save_page

	Capybara::Screenshot.screen_shot_and_open_image

This can be more useful if you disable the auto-generate on failure feature with the following config

	Capybara::Screenshot.autosave_on_failure = false


Example application
-------------------

A simple Rails 3.1 example application has been set up at [https://github.com/mattheworiordan/capybara-screenshot-test-rails-3.1](https://github.com/mattheworiordan/capybara-screenshot-test-rails-3.1)
Git clone the app, and then run Cucumber `rake cucumber`, RSpec `rspec spec/**/*_spec.rb` and Minitest `rake test` and expect intentional failures.
Now check the $APPLICATION_ROOT/tmp/capybara folder for the automatic screen shots generated from failed tests.

Common problems
---------------

If you find that screen shots are not automatically being generated, then it's possible the `capybara-screenshot` gem is loading before your testing framework is loading, and thus unable to determine which framework to hook into.  Make sure you include `capybara-screenshot` gem last in your Gemfile (order is respected by Bundler as of 0.10).  Alternatively, manually require `capybara-screenshot` using one of the following based on your framework:

    require 'capybara-screenshot/cucumber' # For Cucumber support
    require 'capybara-screenshot/rspec' # For RSpec support
    require 'capybara-screenshot/minitest' # For MiniSpec support

[Raise an issue on the Capybara-Screenshot issue tracker](https://github.com/mattheworiordan/capybara-screenshot/issues) if you are still having problems.

Repository
----------

Please fork, submit patches or feedback at [https://github.com/mattheworiordan/capybara-screenshot](https://github.com/mattheworiordan/capybara-screenshot)

The gem details on RubyGems.org can be found at [https://rubygems.org/gems/capybara-screenshot](https://rubygems.org/gems/capybara-screenshot)

About
-----

This gem was written by **Matthew O'Riordan**

 - [http://mattheworiordan.com](http://mattheworiordan.com)
 - [@mattheworiordan](http://twitter.com/#!/mattheworiordan)
 - [Linked In](http://www.linkedin.com/in/lemon)

License
-------

Copyright © 2012 Matthew O'Riordan, inc. It is free software, and may be redistributed under the terms specified in the LICENSE file.