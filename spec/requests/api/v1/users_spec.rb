require 'rails_helper'

RSpec.describe "Api::V1::Users", type: :request do
  describe "GET /me" do
    it "returns http success" do
      get "/api/v1/users/me"
      expect(response).to have_http_status(:success)
    end
  end
end
