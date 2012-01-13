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