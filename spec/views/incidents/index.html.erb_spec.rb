require 'spec_helper'

describe "incidents/index.html.erb" do
  before(:each) do
    assign(:incidents, [
      stub_model(Incident,
        :sid => 1,
        :cid => 1,
        :group_id => 1,
        :user_id => 1,
        :incident_name => "Incident Name",
        :incident_description => "MyText",
        :incident_resolution => "MyText"
      ),
      stub_model(Incident,
        :sid => 1,
        :cid => 1,
        :group_id => 1,
        :user_id => 1,
        :incident_name => "Incident Name",
        :incident_description => "MyText",
        :incident_resolution => "MyText"
      )
    ])
  end

  it "renders a list of incidents" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Incident Name".to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
  end
end
