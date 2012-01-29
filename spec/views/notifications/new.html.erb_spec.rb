require 'spec_helper'

describe "notifications/new" do
  before(:each) do
    assign(:notification, stub_model(Notification,
      :user => nil,
      :email => "MyString",
      :notify_criteria => "MyText"
    ).as_new_record)
  end

  it "renders new notification form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => notifications_path, :method => "post" do
      assert_select "input#notification_user", :name => "notification[user]"
      assert_select "input#notification_email", :name => "notification[email]"
      assert_select "textarea#notification_notify_criteria", :name => "notification[notify_criteria]"
    end
  end
end
