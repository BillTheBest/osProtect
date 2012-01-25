require 'spec_helper'

describe "Login Not Required" do
  it "allows an unauthenticated user to access these pages" do
    visit login_path
    page.should have_content("Login")

    visit logout_path
    page.should have_content("Login")

    visit new_password_reset_path
    page.should have_content("Reset Password")
  end
end
