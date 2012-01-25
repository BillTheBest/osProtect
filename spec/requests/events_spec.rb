require 'spec_helper'

describe "Events" do
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

  it "allows user to view a list of events" do
    sensor = create(:sensor)
    event = create(:event, sid: sensor.sid)
    create(:signature_detail, sig_id: event.signature)
    create(:iphdr, sid: event.sid, cid: event.cid)
    event = create(:event, sid: sensor.sid)
    create(:signature_detail, sig_id: event.signature)
    create(:iphdr, sid: event.sid, cid: event.cid)
    visit events_path
    page.should have_content("priority")
    # (cls) note that the launchy gem requires '> b rake assets:precompile'
    # save_and_open_page # <<<-- launchy gem opens page in browser
  end

  it "allows user to view the details for an event" do
    sensor = create(:sensor)
    event = create(:event, sid: sensor.sid)
    create(:signature_detail, sig_id: event.signature)
    create(:iphdr, sid: event.sid, cid: event.cid)
    visit events_path
    page.should have_content("priority")
    click_link "view"
    page.should have_content("Event Details")
  end
end
