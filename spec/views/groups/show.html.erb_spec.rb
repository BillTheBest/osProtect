require 'spec_helper'

describe "groups/show.html.erb" do
  before(:each) do
    @group = assign(:group, stub_model(Group,
      :user => nil,
      :group_sensor => nil,
      :name => "Name"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(//)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(//)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Name/)
  end
end
