class UserMailer < ApplicationMailer

  def activation_needed_email(user)
    @user = user
    mail to: @user.email,
         subject: "Welcome to GradeCraft! Please activate your account"
  end

  def reset_password_email(user)
    @user = user
    mail(to: user.email, subject: "Your GradeCraft Password Reset Instructions")
  end

  def welcome_email(user)
    @user = user
    mail(to: @user.email, subject: "Welcome to GradeCraft!")
  end
end
