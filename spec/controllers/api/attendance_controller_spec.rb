describe API::AttendanceController do
  context "as a professor", focus: true do
    describe "#create" do
      xit "creates the assignments"
    end
  end

  context "as a student" do
    describe "protected routes" do
      it "redirect with a status 302" do
        [
          -> { post :create }
        ].each do |protected_route|
          expect(protected_route.call).to have_http_status :redirect
        end
      end
    end
  end
end
