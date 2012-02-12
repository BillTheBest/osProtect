class UserMailer < ActionMailer::Base

  if Rails.env.production?
    default from: "do.not.reply@osprotect.appsudo.com"
  else
    default from: "do.not.reply@localhost"
  end

  def password_reset(user_id)
    @user = User.find(user_id)
    # note: subject can be set in your I18n file at config/locales/en.yml with the following lookup:
    #   en.user_mailer.password_reset.subject
    mail :to => @user.email, :subject => "Password Reset"
  end
end
