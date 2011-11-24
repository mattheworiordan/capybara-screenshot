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