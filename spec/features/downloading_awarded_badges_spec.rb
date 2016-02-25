require "rails_spec_helper"

feature "downloading awarded badges file" do
  context "as a professor" do
    let(:course) { create :course, badge_setting: true }
    let!(:course_membership) { create :professor_course_membership, user: professor, course: course }
    let(:professor) { create :user }
    let(:badge) { create :badge, course: course }

    before(:each) do
      login_as professor
      visit dashboard_path
    end

    scenario "successfully" do

      within(".sidebar-container") do
        click_link "Awarded Badges"
      end

      expect(page.response_headers["Content-Type"]).to eq("application/octet-stream")

      expect(page).to have_content "First Name,Last Name,Uniqname,Email,Badge ID,Badge Name,Feedback,Awarded Date"
    end
  end
end
