require 'spec_helper'

describe "PasswordResets" do
  it "emails user when requesting password reset" do
    # new/create actions:
    user = create(:user)
    visit login_path
    click_link "password"
    fill_in "Email", :with => user.email
    click_button "Reset Password"
    current_path.should eq(login_path)
    page.should have_content("Email sent")
    last_email.to.should include(user.email)
  end

  it "does not email invalid user when requesting password reset" do
    # new/create actions:
    visit login_path
    click_link "password"
    fill_in "Email", :with => "nobody@example.com"
    click_button "Reset Password"
    current_path.should eq(new_password_reset_path)
    page.should have_content("Invalid email!")
    last_email.should be_nil
  end

  it "returns to login page when user clicks cancel link" do
    # edit/update actions:
    user = create(:user, :password_reset_token => "something", :password_reset_sent_at => 1.hour.ago)
    visit edit_password_reset_path(user.password_reset_token)
    click_link "cancel"
    current_path.should eq(login_path)
  end

  it "updates the user password when confirmation matches" do
    # edit/update actions:
    user = create(:user, :password_reset_token => "something", :password_reset_sent_at => 1.hour.ago)
    visit edit_password_reset_path(user.password_reset_token)
    fill_in "user_password", :with => "foobar"
    fill_in "user_password_confirmation", :with => "barfoo"
    click_button "Update Password"
    page.should have_content("Password doesn't match confirmation")
    fill_in "user_password", :with => "foobar"
    fill_in "user_password_confirmation", :with => "foobar"
    click_button "Update Password"
    page.should have_content("Password has been reset")
  end

  it "reports when either or both passwords are blank" do
    # edit/update actions:
    user = create(:user, :password_reset_token => "something", :password_reset_sent_at => 1.hour.ago)
    visit edit_password_reset_path(user.password_reset_token)
    # both passwords are blank:
    fill_in "user_password", :with => ""
    fill_in "user_password_confirmation", :with => ""
    click_button "Update Password"
    page.should have_content("Must enter both passwords to reset")
    # password is blank:
    fill_in "user_password", :with => ""
    click_button "Update Password"
    page.should have_content("Must enter both passwords to reset")
    # confirm password is blank:
    fill_in "user_password_confirmation", :with => ""
    click_button "Update Password"
    page.should have_content("Must enter both passwords to reset")
  end

  it "reports when password token has expired" do
    # edit/update actions:
    user = create(:user, :password_reset_token => "something", :password_reset_sent_at => 5.hour.ago)
    visit edit_password_reset_path(user.password_reset_token)
    fill_in "user_password", :with => "foobar"
    fill_in "user_password_confirmation", :with => "foobar"
    click_button "Update Password"
    page.should have_content("Password reset has expired")
  end

  it "raises record not found when password token is invalid" do
    # edit/update actions:
    lambda {
      visit edit_password_reset_path("invalid")
    }.should raise_exception(ActiveRecord::RecordNotFound)
  end
end