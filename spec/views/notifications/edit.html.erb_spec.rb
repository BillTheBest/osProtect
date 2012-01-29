require 'spec_helper'

describe "notifications/edit" do
  before(:each) do
    @notification = assign(:notification, stub_model(Notification,
      :user => nil,
      :email => "MyString",
      :notify_criteria => "MyText"
    ))
  end

  it "renders the edit notification form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => notifications_path(@notification), :method => "post" do
      assert_select "input#notification_user", :name => "notification[user]"
      assert_select "input#notification_email", :name => "notification[email]"
      assert_select "textarea#notification_notify_criteria", :name => "notification[notify_criteria]"
    end
  end
end
