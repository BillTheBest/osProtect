require 'spec_helper'

describe "groups/index.html.erb" do
  before(:each) do
    assign(:groups, [
      stub_model(Group,
        :user => nil,
        :group_sensor => nil,
        :name => "Name"
      ),
      stub_model(Group,
        :user => nil,
        :group_sensor => nil,
        :name => "Name"
      )
    ])
  end

  it "renders a list of groups" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => nil.to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => nil.to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Name".to_s, :count => 2
  end
end
