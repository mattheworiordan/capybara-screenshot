4 Oct 2020 - 1.0.24 -> 1.0.25

* [Fix Cucumber 5 deprecation warnings](https://github.com/mattheworiordan/capybara-screenshot/pull/274)
* [Add support for Cuprite driver](https://github.com/mattheworiordan/capybara-screenshot/pull/270)
* [Rails system spec compatibility](https://github.com/mattheworiordan/capybara-screenshot/pull/264)

24 Nov 2019 - 1.0.23 -> 1.0.24

* [Support Apparition driver](https://github.com/mattheworiordan/capybara-screenshot/commit/273317b241d1d1d8600b32fad998742894424f3b)

10 Jun 2019 - 1.0.22 -> 1.0.23

* [Support for Capybara sessions implicitly](https://github.com/mattheworiordan/capybara-screenshot/pull/255). Thanks https://github.com/TylerRick
* [Support for S3 bucket host configuration](https://github.com/mattheworiordan/capybara-screenshot/pull/252). Thanks https://github.com/machty

21 Oct 2018 - 1.0.21 -> 1.0.22

* [Support for S3 URL in HTML screenshots](https://github.com/mattheworiordan/capybara-screenshot/pull/239)
* [Fix for partial Rails environments](https://github.com/mattheworiordan/capybara-screenshot/pull/238)
* [Capybara 3 support in CI](https://github.com/mattheworiordan/capybara-screenshot/pull/236)

03 May 2018 - 1.0.20 -> 1.0.21

* [Bug fix: Fix Ruby version compares in Gemspec](https://github.com/mattheworiordan/capybara-screenshot/pull/231)

03 May 2018 - 1.0.19 -> 1.0.20

* [Bug fix: Only take screenshots for feature tests](https://github.com/mattheworiordan/capybara-screenshot/pull/223)

10 April 2018 - 1.0.18 -> 1.0.19

* Big thanks for [Geremia Taglialatela](https://github.com/tagliala) for [padding Capybara 3 support and fixing the builds](https://github.com/mattheworiordan/capybara-screenshot/pull/230)

2 November 2017 - 1.0.17 -> 1.0.18

* [RSpec 3.3 support](https://github.com/mattheworiordan/capybara-screenshot/pull/213)
* [Add support for selenium_chrome and selenium_chrome_headless](https://github.com/mattheworiordan/capybara-screenshot/pull/219)
* [Less dependencies for S3 uploads](https://github.com/mattheworiordan/capybara-screenshot/pull/218)

Special thanks to the fine contribution from [Matt Bricston](https://github.com/mattbrictson)

17 July 2017 - 1.0.16 -> 1.0.17

* [Better handling of `page.current_path` exceptions for Spinach](https://github.com/mattheworiordan/capybara-screenshot/pull/208)

12 July 2017 - 1.0.15 -> 1.0.16

* [Support s3 key name prefixes](https://github.com/mattheworiordan/capybara-screenshot/pull/202)

12 July 2017 - 1.0.14 -> 1.0.15

* [SVG badges added](https://github.com/mattheworiordan/capybara-screenshot/pull/207)
* [Ensure the reporter module is not loaded multiple times](https://github.com/mattheworiordan/capybara-screenshot/pull/205)
* [S3 object config option](https://github.com/mattheworiordan/capybara-screenshot/pull/204)
* [Saver can use injected page](https://github.com/mattheworiordan/capybara-screenshot/pull/181)
* [After* callbacks](https://github.com/mattheworiordan/capybara-screenshot/pull/171)

15 Sep 2016 - 1.0.13 -> 1.0.14

* CI stable again - dropped CI support for older versions of Ruby and JRuby.  It is just too painful and there is no evidence that our users need this or that Capybara Screenshot is indeed broken.  It is better to have a reliable build system so that PRs can get merged in reliably and easily.
* Fixed an inconsistency in the use of `save_and_open_page_path`
* Improved debugging of Aruba tests so that contributors can easily understand why their builds break
* Path fixes thanks to [Ryan McGarvey](https://github.com/ryanmcgarvey)

23 May 2016 - 1.0.12 -> 1.0.13

* Fixes [mkmf bug 162](https://github.com/mattheworiordan/capybara-screenshot/issues/162) and [mkmf bug 174](https://github.com/mattheworiordan/capybara-screenshot/issues/174)
* Fix for `Capybara.save_path` method existence assumption

29 March 2016 - 1.0.11 -> 1.0.12

* [Aruba upgrade - passing CI](https://github.com/mattheworiordan/capybara-screenshot/pull/156)
* [imgcat support](https://github.com/mattheworiordan/capybara-screenshot/pull/153)
* [Fix for capaybara root when Rails not defined](https://github.com/mattheworiordan/capybara-screenshot/pull/139)
* [Fix using_session_with_screenshot](https://github.com/mattheworiordan/capybara-screenshot/pull/132)
* [Skip screenshot on skipped test](https://github.com/mattheworiordan/capybara-screenshot/pull/131)
* [Don't output screenshot paths if not saved](https://github.com/mattheworiordan/capybara-screenshot/pull/128)

22 July 2015 - 1.0.10 -> 1.0.11

* [Support for Fuubar reporter](https://github.com/mattheworiordan/capybara-screenshot/pull/137)

Thanks to [Kai Schlichting](https://github.com/lacco)

29 June 2015 - 1.0.9 -> 1.0.10

* [Small fix to memoization](https://github.com/mattheworiordan/capybara-screenshot/pull/134) plus [mini refactor](https://github.com/mattheworiordan/capybara-screenshot/commit/1db950bc53c729b26b8881d058a8781d6e7611b8)

Thanks to [Systho](https://github.com/Systho)

6 April 2015 - 1.0.8 -> 1.0.9
-----------

* [Improved file links within screenshot output](https://github.com/mattheworiordan/capybara-screenshot/pull/123)

Thanks to [Jan Lelis](https://github.com/janlelis)

6 April 2015 - 1.0.7 -> 1.0.8
-----------

* Less aggressive pruning

9 March 2015 - 1.0.6 -> 1.0.7
-----------

* Fix capybara-webkit bug, see https://github.com/mattheworiordan/capybara-screenshot/issues/119
* Fix Travis CI builds in Ruby < 2.1 and added Ruby 2.2 support

8 March 2015 - 1.0.5 -> 1.0.6
-----------

* Removed dependency on the colored gem

Thanks to [François Bernier](https://github.com/fbernier)

10 Feburary 2015 - 1.04 -> 1.0.5
-----------

* Added support for appending a random string to the filename

Thanks to [Brad Wedell](https://github.com/streetlogics)

5 January 2015 - 1.0.3 -> 1.0.4
-----------

* Added support for Poltergeist Billy
* Don't initialize a new Capybara::Session in after hook

Thanks to [Neodude](https://github.com/neodude) and [Dominik Masur](https://github.com/dmasur)

1 October 2014 - 1.0.2 -> 1.0.3
-----------

* Added ability to prune screenshots automatically, see https://github.com/mattheworiordan/capybara-screenshot/pull/100

Thanks to [Anton Kolomiychuk](https://github.com/akolomiychuk) for his contribution.

27 September 2014 - 1.0.1 -> 1.0.2
-----------

* Improved documentation to cover RSpec 3's new approach to using `rails_helper` in place of `spec_helper` for Rails tests
* Updated documentation to use Ruby formatting in language blocks
* Removed need to manually `require 'capybara-screenshot'` for RSpec

18 September 2014 - 1.0.0 -> 1.0.1
-----------

* Hot fix for RSpec version issue that assumed RSpec base library was always available, now uses `RSpec::Core::VERSION`
* Improve Travis CI performance and stability

18 September 2014 - 0.3.22 -> 1.0.0
-----------

Because of the broad test coverage now across RSpec, Cucumber, Spinach, Minitest and TestUnit using [Aruba](https://github.com/cucumber/aruba), I feel that this gem is ready for its first major release.  New features and refactoring can now reliably be done  without the fear of regressions.

The major changes in this 1.0 release are:

* Acceptance test coverage for RSpec, Cucumber, Spinach, Minitest and TestUnit
* Travis CI test coverage across a matrix of old and new versions of the aforementioned testing frameworks, see https://github.com/mattheworiordan/capybara-screenshot/blob/master/.travis.yml
* Support for RSpec 3 using the custom formatters
* Support for sessions using `using_session`, see https://github.com/mattheworiordan/capybara-screenshot/pull/91 for more info
* Support for RSpec DocumentationFormatter
* Considerable refactoring of the test suite

Special thanks goes to [Andrew Brown](https://github.com/dontfidget) who has contributed a huge amount of the code that has helped enable this Gem to have its stable major version release.

22 July 2014 - 0.3.21 -> 0.3.22
-----------

Replaced [colorize](https://rubygems.org/gems/colorize) gem with [colored](https://rubygems.org/gems/colored) due to license issue, see https://github.com/mattheworiordan/capybara-screenshot/issues/93.

22 July 2014 - 0.3.20 -> 0.3.21
-----------

As a result of recent merges and insufficient test coverage, it seems that for test suites other than RSpec the HTML or Image screenshot path was no longer being outputted in the test results.  This has now been fixed, and screenshot output format for RSpec and all other test suites has been standardised.

11 July 2014 - 0.3.19 -> 0.3.20
-----------

* Added reporters to improve screenshot info in RSpec output
* Added support for Webkit options such as width and height

Thanks to https://github.com/multiplegeorges and https://github.com/noniq

2 April 2014 - 0.3.18 -> 0.3.19
-----------

* Added support Spinach, thanks to https://github.com/suchitpuri

2 March 2014 - 0.3.16 -> 0.3.17
-----------

* Added support for RSpec 3 and cleaned up the logging so there is less noise within the test results when a driver does not support a particular format.
* Updated Travis to test against Ruby 2.0 and Ruby 2.1

Thanks to https://github.com/noniq

7 January 2014
-----------

Bug fix for Minitest 5, thanks to https://github.com/cschramm


12 September 2013
-----------

Added support for Test Unit, fixed RSpec deprecation warnings and fixed a dependency issue.

Thanks to:

* https://github.com/budnik
* https://github.com/jkraemer
* https://github.com/mariovisic


23 July 2013
-----------

https://github.com/stevenwilkin contributed code to display a warning for [Mechanize](http://mechanize.rubyforge.org/) users.

3 June 2013
-----------

Dropped Ruby 1.8 support for this Gem because of conflicts with Nokogiri requiring a later version of Ruby.  Instead, there is a new branch https://github.com/mattheworiordan/capybara-screenshot/tree/ruby-1.8-support which can be used if requiring backwards compatabiltiy.

18 Apr 2013
-----------

Improved documentation, Ruby 1.8.7 support by not allowing Capybara 2.1 to be used, improved Sinatra support.
RSpec screenshot fix to only screenshot when applicable: https://github.com/mattheworiordan/capybara-screenshot/issues/44

07 Jan 2013
-----------

Support for Terminus, thanks to https://github.com/jamesotron

27 Dec 2012
-----------

Previos version bump broke Ruby 1.8.7 support, so Travis CI build added to this Gem and Ruby 1.8.7 support along with JRuby support added.

30 Oct 2012 - Significant version bump 0.3
-----------

After some consideration, and continued problems with load order of capybara-screenshot in relation to other required gems, the commits from @adzap in the pull request https://github.com/mattheworiordan/capybara-screenshot/pull/29 have been incorporated.  Moving forwards, for every testing framework you use, you will be required to add an explicit require.


15 Feb 2012
-----------

Merged pull request https://github.com/mattheworiordan/capybara-screenshot/pull/14 to limit when capybara-screenshot is fired for RSpec

30 Jan 2012
-----------

Merged pull request from https://github.com/hlascelles to support Padrino

15 Jan 2012
-----------

Removed unnecessary and annoying warning that a screen shot cannot be taken.  This message was being shown when RSpec tests were run that did not even invoke Capybara

13 Jan 2012
-----------

Updated documentation to reflect support for more frameworks, https://github.com/mattheworiordan/capybara-screenshot/issues/9

3 Jan 2012
----------

Removed Cucumber dependency https://github.com/mattheworiordan/capybara-screenshot/issues/7
Allowed PNG save path to be configured using capybara.save_and_open_page_path

3 December 2011
---------------

More robust handling of Minitest for users who have it installed as a dependency
https://github.com/mattheworiordan/capybara-screenshot/issues/5


2 December 2011
---------------

Fixed bug related to teardown hook not being available in Minitest for some reason (possibly version issues).
https://github.com/mattheworiordan/capybara-screenshot/issues/5

24 November 2011
----------------

Added support for:

 * More platforms (Poltergeist)
 * Removed Rails dependencies (bug)
 * Added screenshot capability for Selenium
 * Added support for embed for HTML reports

Thanks to [https://github.com/rb2k](https://github.com/rb2k) for 2 [great commits](https://github.com/mattheworiordan/capybara-screenshot/pull/4)

16 November 2011
----------------

Added support for Minitest using teardown hooks


16 November 2011
----------------

Added support for RSpec by adding a RSpec configuration after hook and checking if Capybara is being used.

15 November 2011
----------------

Ensured that tests run other than Cucumber won't fail.  Prior to this Cucumber was required.
