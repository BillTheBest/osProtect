require 'spec_helper'

describe "Sensors" do
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

  it "allows user to view a list of sensors" do
    # create some sensors to view:
    create(:sensor)
    create(:sensor)
    visit sensors_path
    page.should have_content("Sensors")
    # (cls) note that the launchy gem requires '> b rake assets:precompile'
    # save_and_open_page # <<<-- launchy gem opens page in browser
  end
end
