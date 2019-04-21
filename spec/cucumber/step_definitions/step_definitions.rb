When(/^I click on a missing link$/) do
  click_on "you'll never find me"
end

When(/^I click on a missing link on a different page in a different session$/) do
  using_session :different_session do
    visit '/different_page'
    click_on "you'll never find me"
  end
end

When(/^I visit "([^"]*)"$/) do |path|
  visit path
end

Then(/^I trigger an unhandled exception/) do
  raise "you can't handle me"
end

Then(/^I save the page with a custom prefix$/) do
  screenshot_and_save_page filename_prefix: 'custom_prefix'
end

Then(/^I take a screenshot which is not saved$/) do
  screenshot_and_save_page save_html: false
end
