describe UserMailer do
  extend Toolkits::Mailers::EmailToolkit::Definitions # brings in helpers for default emails and parts
  define_email_context # taken from the definitions toolkit

  include Toolkits::Mailers::EmailToolkit::SharedExamples # brings in shared examples for emails and parts
  let(:user) { create :user, reset_password_token: "blah" }

  describe "#reset_password_email" do
    before(:each) { UserMailer.reset_password_email(user).deliver_now }

    it "is sent from a notifications email" do
      expect(email.from).to eq ["mailer@gradecraft.com"]
    end

    it "is sent to the user's email" do
      expect(email.to).to eq [user.email]
    end

    it "has an appropriate subject" do
      expect(email.subject).to eq "Your GradeCraft Password Reset Instructions"
    end

    it "has the password reset link" do
      expect(text_part.body).to include edit_password_url("blah")
    end
  end

  describe "#activation_needed_email" do
    let(:user) { create :user }

    before(:each) do
      user.update_attribute :activation_token, "blah"
      UserMailer.activation_needed_email(user).deliver_now
    end

    it "is sent from the a notifications email" do
      expect(email.from).to eq ["mailer@gradecraft.com"]
    end

    it "is sent to the user's email" do
      expect(email.to).to eq [user.email]
    end

    it "has an appropriate subject" do
      expect(email.subject).to eq "Welcome to GradeCraft! Please activate your account"
    end

    it "has the activation link" do
      expect(text_part.body).to include activate_user_url("blah")
    end
  end

  describe ".welcome_email" do
    let(:user) { create :user }

    before(:each) do
      UserMailer.welcome_email(user).deliver_now
    end

    it "is sent from the a notifications email" do
      expect(email.from).to eq ["mailer@gradecraft.com"]
    end

    it "is sent to the user's email" do
      expect(email.to).to eq [user.email]
    end

    it "has an appropriate subject" do
      expect(email.subject).to eq "Welcome to GradeCraft!"
    end

    it "has a link to the dashboard" do
      expect(text_part.body).to include dashboard_url
    end
  end

  describe "#resources_email" do
    let(:user) { create :user }

    before(:each) do
      UserMailer.resources_email(user).deliver_now
    end

    it "is sent from the a notifications email" do
      expect(email.from).to eq ["mailer@gradecraft.com"]
    end

    it "is sent to the user's email" do
      expect(email.to).to eq [user.email]
    end

    it "has an appropriate subject" do
      expect(email.subject).to eq "GradeCraft Resources!"
    end
  end
end
