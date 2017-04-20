require "./app/services/imports_lms_users/retrieves_lms_users"

describe Services::Actions::RetrievesLMSUsers do
  let(:access_token) { "TOKEN" }
  let(:provider) { "canvas" }
  let(:course_id) { "123" }

  it "expects the provider to retrieve the users from" do
    expect { described_class.execute access_token: access_token, course_id: course_id }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "expects the access token to use to retrieve the users" do
    expect { described_class.execute provider: provider, course_id: course_id }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "expects the id of the course to retrieve the users" do
    expect { described_class.execute provider: provider, access_token: access_token }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "retrieves the user details from the lms provider" do
    expect(ActiveLMS::Syllabus).to \
      receive(:new).with(provider, access_token).and_call_original

    expect_any_instance_of(ActiveLMS::Syllabus).to \
      receive(:users).with(course_id, true)
        .and_return({})

    described_class.execute provider: provider, access_token: access_token,
      course_id: course_id
  end
end
