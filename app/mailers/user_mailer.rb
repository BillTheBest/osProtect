class UserMailer < ActionMailer::Base
  default from: "from@localhost"

  def password_reset(user)
    @user = user
    # note: subject can be set in your I18n file at config/locales/en.yml with the following lookup:
    #   en.user_mailer.password_reset.subject
    mail :to => user.email, :subject => "Password Reset"
  end
end
