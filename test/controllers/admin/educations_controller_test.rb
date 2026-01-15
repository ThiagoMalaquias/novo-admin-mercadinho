require "test_helper"

class Admin::EducationsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get admin_educations_index_url
    assert_response :success
  end
end
