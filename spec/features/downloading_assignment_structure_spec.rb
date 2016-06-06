require "rails_spec_helper"

feature "downloading assignment structure file" do
  context "as a professor" do
    let(:course) { create :course }
    let!(:course_membership) { create :professor_course_membership, user: professor, course: course }
    let(:professor) { create :user }

    before(:each) do
      login_as professor
      visit dashboard_path
    end

    scenario "successfully" do

      within(".sidebar-container") do
        click_link "Assignment Structure"
      end

      expect(page.response_headers["Content-Type"]).to eq("application/octet-stream")

      expect(page).to have_content "Assignment ID,Name,Point Total,Description,Open At,Due At,Accept Until"
    end
  end
end
