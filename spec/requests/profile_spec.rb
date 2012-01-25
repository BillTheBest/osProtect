require 'spec_helper'

describe "Profile" do
  before(:each) do
    user = create(:user)
    visit login_path
    fill_in "Username", :with => user.username
    fill_in "Password", :with => user.password
    click_button "Login"
    current_path.should eq(root_path)
    # this verifies that current_user is set for the layouts/application.html.erb page:
    page.should have_content(user.username)
    page.should have_content("Logged in!")
  end

  it "allows a user to update their profile" do
    # edit/update actions:
    user = create(:user)

    visit edit_user_path(user)
    fill_in "user_username", :with => ""
    click_button "Update Profile"
    page.should have_content("Username can't be blank")

    visit edit_user_path(user)
    fill_in "user_username", :with => "spud"
    click_button "Update Profile"
    page.should have_content("Successfully updated profile.")
  end
end
