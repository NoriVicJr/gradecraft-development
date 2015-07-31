#spec/controllers/tasks_controller_spec.rb
require 'spec_helper'

describe TasksController do

	context "as a professor" do 
		describe "GET index"
		describe "GET new"
		describe "GET edit"
		describe "GET create"
		describe "GET show"
		describe "GET update"
		describe "GET destroy"
	end

	context "as a student" do
		describe "protected routes" do
      [
        :index,
        :new,
        :edit,
        :create,
        :show,
        :update,
        :destroy
      ].each do |route|
          it "#{route} redirects to root" do
            pending
            (get route).should redirect_to(:root)
          end
        end
    end

	end
end