require 'spec_helper'

describe "Users" do
  it "allows a user to log in" do
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

  it "does not allow an unknown user to log in" do
    visit login_path
    fill_in "Username", :with => "unknown???"
    fill_in "Password", :with => "unknown"
    click_button "Login"
    current_path.should eq(sessions_path)
    page.should have_content("Login")
    page.should have_content("Invalid username or password")
    # (cls) note that the launchy gem requires '> b rake assets:precompile'
    # save_and_open_page # <<<-- launchy gem opens page in browser
  end
end
