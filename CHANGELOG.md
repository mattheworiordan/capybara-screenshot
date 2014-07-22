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
