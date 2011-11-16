capybara-screenshot gem
=======================

Using this gem, whenever a [capybara](https://github.com/jnicklas/capybara) [cucumber](http://cukes.info/) scenario fails, the HTML for the failed page and a screenshot (when using [capybara-webkit](https://github.com/thoughtbot/capybara-webkit)) is saved into /tmp/capybara.

This is a huge help when trying to diagnose a problem in your failing steps as you can view the source code and potentially how the page looked at the time of the failure.

Usage
-----

    gem install capybara-screenshot

or update your Gemfile to include:

    group :test do
      gem 'capybara-screenshot'
    end

That's it!

Example application
-------------------

A simple Rails 3.1 example application has been set up at [https://github.com/mattheworiordan/capybara-screenshot-test-rails-3.1](https://github.com/mattheworiordan/capybara-screenshot-test-rails-3.1)
Git clone the app, and then run Cucumber `rake cucumber` or RSpec `rspec spec/**/*_spec.rb` and expect failures.
Then check the tmp/capybara folder for the automatic screen shots generated from failed tests.

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

Copyright © 2011 Matthew O'Riordan, inc. It is free software, and may be redistributed under the terms specified in the LICENSE file.