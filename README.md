capybara-screenshot gem
=======================

[![Build Status](https://travis-ci.org/mattheworiordan/capybara-screenshot.svg)](https://travis-ci.org/mattheworiordan/capybara-screenshot)
[![Code Climate](https://d3s6mut3hikguw.cloudfront.net/github/mattheworiordan/capybara-screenshot.svg)](https://codeclimate.com/github/mattheworiordan/capybara-screenshot)
[![Gem Version](https://badge.fury.io/rb/capybara-screenshot.svg)](http://badge.fury.io/rb/capybara-screenshot)

#### Capture a screen shot for every test failure automatically!

`capybara-screenshot` used with [Capybara](https://github.com/jnicklas/capybara) and [Cucumber](http://cukes.info/), [Rspec](https://www.relishapp.com/rspec) or [Minitest](https://github.com/seattlerb/minitest), will capture a screen shot for each failure in your test suite.  The HTML for the failed page, and a screenshot image (when using [capybara-webkit](https://github.com/thoughtbot/capybara-webkit), [Selenium](http://seleniumhq.org/) or [poltergeist](https://github.com/jonleighton/poltergeist)) is saved into `$APPLICATION_ROOT/tmp/capybara`.

Having screenshots readily available for each test failure is incredibly helpful when trying to quickly diagnose a problem in your failing steps.  You can view the source code, and have a screen shot of the page (when applicable), at the time of each failure.

_Please note that Ruby 1.9+ is required to use this Gem.  For Ruby 1.8 support, please see the [capybara-screenshot Ruby 1.8 branch](https://github.com/mattheworiordan/capybara-screenshot/tree/ruby-1.8-support)_

Installation
-----

### Step 1: install the gem

Using Bundler, add the following to your Gemfile

```ruby
gem 'capybara-screenshot', :group => :test
```

or install manually using Ruby Gems:

```
gem install capybara-screenshot
```

### Step 2: load capybara-screenshot into your tests

#### Cucumber

In env.rb or a support file, please add:

```ruby
require 'capybara-screenshot/cucumber'
```

#### RSpec

In rails_helper.rb, spec_helper.rb, or a support file, after the require for 'capybara/rspec', please add:

```ruby
# remember: you must require 'capybara/rspec' first
require 'capybara-screenshot/rspec'
```

*Note: As of RSpec Rails 3.0, it is recommended that all your Rails environment code is loaded into `rails_helper.rb` instead of `spec_helper.rb`, and as such, the capybara-screenshot require should be located in `rails_helper.rb`.  See the [RSpec Rails 3.0 upgrade notes](https://www.relishapp.com/rspec/rspec-rails/v/3-0/docs/upgrade) for more info.*

#### Minitest

Typically in 'test/test_helper.rb', please add:

```ruby
require 'capybara-screenshot/minitest'
```

Also, consider adding `include Capybara::Screenshot::MiniTestPlugin` to any test classes that fail. For example, to capture screenshots for all failing integration tests in minitest-rails, try something like:

```ruby
class ActionDispatch::IntegrationTest
  include Capybara::Screenshot::MiniTestPlugin
  # ...
end
```

#### Test::Unit

Typically in 'test/test_helper.rb', please add:

```ruby
require 'capybara-screenshot/testunit'
```

By default, screenshots will be captured for `Test::Unit` tests in the path 'test/integration'.  You can add additional paths as:

```ruby
Capybara::Screenshot.testunit_paths << 'test/feature'
```


Manual screenshots
----

If you require more control, you can generate the screenshot on demand rather than on failure. This is useful
if the failure occurs at a point where the screen shot is not as useful for debugging a rendering problem. This
can be more useful if you disable the auto-generate on failure feature with the following config

```ruby
Capybara::Screenshot.autosave_on_failure = false
```

Anywhere the Capybara DSL methods (visit, click etc.) are available so too are the screenshot methods.

```ruby
screenshot_and_save_page
```

Or for screenshot only, which will automatically open the image.

```ruby
screenshot_and_open_image
```

These are just calls on the main library methods.

```ruby
Capybara::Screenshot.screenshot_and_save_page
Capybara::Screenshot.screenshot_and_open_image
```

Better looking HTML screenshots
-------------------------------

By the default, HTML screenshots will not look very good when opened in a browser.  This happens because the browser can't correctly resolve relative paths like `<link href="/assets/...." />`, which stops CSS, images, etc... from beind loaded.  To get a nicer looking page, configure Capybara with:

```ruby
Capybara.asset_host = 'http://localhost:3000'
```

This will cause Capybara to add `<base>http://localhost:3000</base>` to the HTML file, which gives the browser enough information to resolve relative paths.  Next, start a rails server in development mode, on port 3000, to respond to requests for assets:

```bash
rails s -p 3000
```

Now when you open the page, you should have something that looks much better.  You can leave this setup in place and use the default HTML pages when you don't care about the presentation, or start the rails server when you need something better looking.  

Driver configuration
--------------------

The gem supports the default rendering method for Capybara to generate the screenshot, which is:

```ruby
page.driver.render(path)
```

There are also some specific driver configurations for Selenium, Webkit, and Poltergeist. See [the definitions here](https://github.com/mattheworiordan/capybara-screenshot/blob/master/lib/capybara-screenshot.rb). The Rack::Test driver, Rails' default, does not allow
rendering, so it has a driver definition as a noop.

Capybara-webkit defaults to a screenshot size of 1000px by 10px. To specify a custom size, use the following option:

```ruby
Capybara::Screenshot.webkit_options = { width: 1024, height: 768 }
```

If a driver is not found the default rendering will be used. If this doesn't work with your driver, then you can
add another driver configuration like so

```ruby
# The driver name should match the Capybara driver config name.
Capybara::Screenshot.register_driver(:exotic_browser_driver) do |driver, path|
  driver.super_dooper_render(path)
end
```

If your driver is based on existing browser driver, like Firefox, instead of `.super_dooper_render` do `driver.browser.save_screenshot path`.


Custom screenshot filename
--------------------------

If you want to control the screenshot filename for a specific test library, to inject the test name into it for example,
you can override how the basename is generated for the file like so

```ruby
Capybara::Screenshot.register_filename_prefix_formatter(:rspec) do |example|
  "screenshot_#{example.description.gsub(' ', '-').gsub(/^.*\/spec\//,'')}"
end
```

By default capybara-screenshot will append a timestamp to the basename. If you want to disable this behavior set the following option:

```ruby
Capybara::Screenshot.append_timestamp = false
```


Custom screenshot directory
--------------------------
By default, when running under Rails, Sinatra, and Padrino, screenshots are saved into `$APPLICATION_ROOT/tmp/capybara`. Otherwise, they're saved under `Dir.pwd`.
If you want to customize the location, override the file path as:

```ruby
Capybara.save_path = "/file/path"
```

Usage with multiple Capybara sessions
-------------------------------------

To make screenshots work with multiple Capybara sessions, replace `Capybara.using_session` with `Capybara.using_session_with_screenshot`:

```ruby
Cabybara.using_session_with_screenshot('User 1') do
  # screenshots will work and use the correct session
end
```


Uploading screenshots to S3
--------------------------
You can configure capybara-screenshot to automatically save your screenshots to an AWS S3 bucket.

First, install the `aws-sdk-s3` gem or add it to your Gemfile

```ruby
gem 'aws-sdk-s3', group: :test
gem 'capybara-screenshot', group: :test
```

Next, configure capybara-screenshot with your S3 credentials, the bucket to save to, and an optional region (default: `us-east-1`).

```ruby
Capybara::Screenshot.s3_configuration = {
  s3_client_credentials: {
    access_key_id: "my_access_key_id",
    secret_access_key: "my_secret_access_key",
    region: "eu-central-1"
  },
  bucket_name: "my_screenshots"
}
```

It is also possible to specify the object parameters such as acl.
Configure the capybara-screenshot with these options in this way:

```ruby
Capybara::Screenshot.s3_object_configuration = {
  acl: 'public-read'
}
```

You may optionally specify a `:key_prefix` when generating the S3 keys, which can be used to create virtual [folders](http://docs.aws.amazon.com/AmazonS3/latest/UG/FolderOperations.html) in S3, e.g.:

```ruby
Capybara::Screenshot.s3_configuration = {
  ... # other config here
  key_prefix: "some/folder/"
}
```

Pruning old screenshots automatically
--------------------------
By default screenshots are saved indefinitely, if you want them to be automatically pruned on a new failure, then you can specify one of the following prune strategies as follows:

```ruby
# Keep only the screenshots generated from the last failing test suite
Capybara::Screenshot.prune_strategy = :keep_last_run

# Keep up to the number of screenshots specified in the hash
Capybara::Screenshot.prune_strategy = { keep: 20 }
```

Callbacks
---------

You can hook your own logic into callbacks after the html/screenshot has been saved.

```ruby
# after Saver#save_html
Capybara::Screenshot.after_save_html do |path|
  mail = Mail.new do
    delivery_method :sendmail
    from     'capybara-screenshot@example.com'
    to       'dev@example.com'
    subject  'Capybara Screenshot'
    add_file File.read path
  end
  mail.delivery_method :sendmail
  mail.deliver
end

# after Saver#save_screenshot
Capybara::Screenshot.after_save_screenshot do |path|
  # ...
end
```

Information about screenshots in RSpec output
---------------------------------------------

By default, capybara-screenshot extend RSpec’s formatters to include a link to the screenshot and/or saved html page for each failed spec. If you want to disable this feature completely (eg. to avoid problems with CI tools), use:

```ruby
Capybara::Screenshot::RSpec.add_link_to_screenshot_for_failed_examples = false
```

It’s also possible to directly embed the screenshot image in the output if you’re using RSpec’s HtmlFormatter:

```ruby
Capybara::Screenshot::RSpec::REPORTERS["RSpec::Core::Formatters::HtmlFormatter"] = Capybara::Screenshot::RSpec::HtmlEmbedReporter
```

If you want to further customize the information added to RSpec’s output, just implement your own reporter class and customize `Capybara::Screenshot::RSpec::REPORTERS` accordingly. See [rspec.rb](lib/capybara-screenshot/rspec.rb) for more info.


Common problems
---------------

If you have recently upgraded from v0.2, or you find that screen shots are not automatically being generated, then it's most likely you have not included the necessary `require` statement for your testing framework described above.  As of version 0.3, without the explicit require, Capybara-Screenshot will not automatically take screen shots.  Please re-read the installation instructions above.

Also make sure that you're not calling `Capybara.reset_sessions!` before the screenshot hook runs. For RSpec you want to make sure that you're using `append_after` instead of `after`, for instance:

```ruby
config.append_after(:each) do
  Capybara.reset_sessions!
end
```

[Raise an issue on the Capybara-Screenshot issue tracker](https://github.com/mattheworiordan/capybara-screenshot/issues) if you are still having problems.

Repository & Contributing to this Gem
-------------------------------------

#### Bugs

Please raise an issue at [https://github.com/mattheworiordan/capybara-screenshot/issues](https://github.com/mattheworiordan/capybara-screenshot/issues) and ensure you provide sufficient detail to replicate the problem.

#### Contributions

Contributions are welcome.  Please fork this gem, and submit a pull request.  New features must include test coverage and must pass on all versions of the testing frameworks supported.  Run `appraisal` to set up the your Gems. then `appraisal "rake travis:ci"` locally to test your changes against all versions of testing framework gems supported.

#### Rubygems

The gem details on RubyGems.org can be found at [https://rubygems.org/gems/capybara-screenshot](https://rubygems.org/gems/capybara-screenshot)

About
-----

This gem was written by **Matthew O'Riordan**, with contributions from [many kind people](https://github.com/mattheworiordan/capybara-screenshot/network/members).

 - [http://mattheworiordan.com](http://mattheworiordan.com)
 - [@mattheworiordan](http://twitter.com/#!/mattheworiordan)
 - [Linked In](http://www.linkedin.com/in/lemon)

License
-------

Copyright © 2016 Matthew O'Riordan, inc. It is free software, and may be redistributed under the terms specified in the LICENSE file.
