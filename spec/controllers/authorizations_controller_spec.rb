describe AuthorizationsController do
  describe "GET #create" do
    context "as a professor" do
      let(:canvas_auth_hash) do
        {
          provider: provider,
          credentials: {
            token: "BLAH",
            refresh_token: "REFRESH",
            expires_at: expires_at.to_i,
            expires: true
          }
        }.deep_stringify_keys
      end
      let(:expires_at) { Time.now + (30 * 24 * 60 * 60) }
      let(:professor) { professor_membership.user }
      let(:professor_membership) { create :course_membership, :professor }
      let(:provider) { :canvas }

      before do
        request.env["omniauth.auth"] = canvas_auth_hash
        login_user(professor)
      end

      context "for a new authorization" do
        it "creates the authorization for the user and provider" do
          get :create, params: { provider: provider }

          authorization = UserAuthorization.unscoped.last

          expect(authorization).to_not be_nil
          expect(authorization.user_id).to eq professor.id
        end

        it "redirects back to the referrer" do
          session[:return_to] = courses_path

          get :create, params: { provider: provider }

          expect(response).to redirect_to courses_path
        end
      end
    end
  end

  describe "GET #create_for_google" do
    context "as a professor" do
      let(:google_oauth2_hash) do
        {
          provider: provider,
          credentials: {
            token: "BLAH",
            refresh_token: "REFRESH",
            expires_at: expires_at.to_i,
            expires: true
          },
          info: {
            email: professor.email
          }
        }.deep_stringify_keys
      end
      let(:expires_at) { Time.now + (30 * 24 * 60 * 60) }
      let(:professor) { professor_membership.user }
      let(:professor_membership) { create :course_membership, :professor }
      let(:provider) { :google_oauth2 }

      before do
        request.env["omniauth.auth"] = google_oauth2_hash
      end

      context "for a new authorization" do
        it "creates the authorization for the user and provider" do
          get :create_for_google, params: { provider: provider }

          authorization = UserAuthorization.unscoped.last

          expect(authorization).to_not be_nil
          expect(authorization.user_id).to eq professor.id
        end

        it "logs the user in with the authorization" do
          session[:return_to] = courses_path

          get :create_for_google, params: { provider: provider }

          expect(session["user_id"]).to eq(professor.id.to_s)
        end
      end



      context "for a new authorization" do

        before do
          request.env["omniauth.auth"] = nil
        end

        it "redirects to auth failure page" do
          get :create_for_google, params: { provider: provider }

          authorization = UserAuthorization.unscoped.last

          expect(response).to redirect_to auth_failure_path
        end
      end
    end
  end
end
