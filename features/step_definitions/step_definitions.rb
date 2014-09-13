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

Then(/^I run the feature file named "([^"]*)" with cucumber$/) do |arg|
  run_simple "#{Cucumber::BINARY} #{arg} -r ../../features", false
end

Given(/^a screenshot failure file named "([^"]*)"$/) do |arg|
  Capybara::Screenshot.append_timestamp = false
  Capybara::Screenshot.register_filename_prefix_formatter(:cucumber) do |example|
    arg
  end
end
