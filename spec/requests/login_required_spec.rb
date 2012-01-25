require 'spec_helper'

describe "Login Required" do
  it "does not allow an unauthenticated user to access these pages and redirects them to the login page" do
    visit root_path
    visit logout_path
    visit pulse_path
    visit sensors_path
    visit events_path
    event = create(:event)
    visit event_path(event)
    visit users_path
  end

  after(:each) do
    page.should have_content("Login")
  end
end
