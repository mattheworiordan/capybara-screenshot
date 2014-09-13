Feature: Saving a screenshot
  Scenario: When the failure occurs
    When I write to "failing.feature" with:
      """
      @restore-capybara-default-session
      Feature: Failure
      Scenario: Failure
        Given a screenshot failure file named "my_screenshot"
        When I visit "/"
        And I click on a missing link
      """
    And I run the feature file named "failing.feature" with cucumber
    Then the file "tmp/my_screenshot.html" should contain:
    """
    This is the root page
    """

  Scenario: When the failure occurs in a different browser session than the original session
    When I write to "failing.feature" with:
      """
      @restore-capybara-default-session
      Feature: Failure
      Scenario: Failure
        Given a screenshot failure file named "my_screenshot"
        When I visit "/"
        And I click on a missing link on a different page in a different session
      """
    And I run the feature file named "failing.feature" with cucumber
    Then the file "tmp/my_screenshot.html" should contain:
      """
      This is a different page
      """
