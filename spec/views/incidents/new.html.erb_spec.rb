require 'spec_helper'

describe "incidents/new.html.erb" do
  before(:each) do
    assign(:incident, stub_model(Incident,
      :sid => 1,
      :cid => 1,
      :group_id => 1,
      :user_id => 1,
      :incident_name => "MyString",
      :incident_description => "MyText",
      :incident_resolution => "MyText"
    ).as_new_record)
  end

  it "renders new incident form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => incidents_path, :method => "post" do
      assert_select "input#incident_sid", :name => "incident[sid]"
      assert_select "input#incident_cid", :name => "incident[cid]"
      assert_select "input#incident_group_id", :name => "incident[group_id]"
      assert_select "input#incident_user_id", :name => "incident[user_id]"
      assert_select "input#incident_incident_name", :name => "incident[incident_name]"
      assert_select "textarea#incident_incident_description", :name => "incident[incident_description]"
      assert_select "textarea#incident_incident_resolution", :name => "incident[incident_resolution]"
    end
  end
end
