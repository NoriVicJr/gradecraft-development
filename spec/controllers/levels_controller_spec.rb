require "rails_spec_helper"

describe LevelsController do
  before(:all) do
    @course = create(:course)
  end
  before(:each) do
    session[:course_id] = @course.id
    allow(Resque).to receive(:enqueue).and_return(true)
  end

  context "as a professor" do
    before(:all) do
      @professor = create(:user)
      CourseMembership.create user: @professor, course: @course, role: "professor"
    end

    before(:each) { login_user(@professor) }

    describe "POST create" do
      it "creates a new level" do
        params = attributes_for(:level)
        expect{ post :create, :level => params }.to change(Level,:count).by(1)
      end
    end

    describe "GET destroy" do
      it "destroys a level" do
        @level = create(:level)
        expect{ get :destroy, { :id => @level } }.to change(Level,:count).by(-1)
      end
    end

    describe "POST update" do
      it "updates a level" do
        @level = create(:level)
        params = { name: "new name" }
        post :update, id: @level.id, :level=> params
        expect(@level.reload.name).to eq("new name")
      end
    end
  end

  context "as a student" do
    before(:all) do
      @student = create(:user)
      @student.courses << @course
    end
    before(:each) { login_user(@student) }

    describe "protected routes" do
      [
        :create
      ].each do |route|
          it "#{route} redirects to root" do
            expect(get route).to redirect_to(:root)
          end
        end
    end

    describe "protected routes requiring id in params" do
      [
        :update,
        :destroy
      ].each do |route|
        it "#{route} redirects to root" do
          expect(get route, {:id => "10"}).to redirect_to(:root)
        end
      end
    end
  end
end
