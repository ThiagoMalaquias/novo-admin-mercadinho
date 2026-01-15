require "test_helper"

class InstitucionalVideosControllerTest < ActionDispatch::IntegrationTest
  setup do
    @institucional_video = institucional_videos(:one)
  end

  test "should get index" do
    get institucional_videos_url
    assert_response :success
  end

  test "should get new" do
    get new_institucional_video_url
    assert_response :success
  end

  test "should create institucional_video" do
    assert_difference('InstitucionalVideo.count') do
      post institucional_videos_url, params: { institucional_video: { company_id: @institucional_video.company_id, url: @institucional_video.url } }
    end

    assert_redirected_to institucional_video_url(InstitucionalVideo.last)
  end

  test "should show institucional_video" do
    get institucional_video_url(@institucional_video)
    assert_response :success
  end

  test "should get edit" do
    get edit_institucional_video_url(@institucional_video)
    assert_response :success
  end

  test "should update institucional_video" do
    patch institucional_video_url(@institucional_video), params: { institucional_video: { company_id: @institucional_video.company_id, url: @institucional_video.url } }
    assert_redirected_to institucional_video_url(@institucional_video)
  end

  test "should destroy institucional_video" do
    assert_difference('InstitucionalVideo.count', -1) do
      delete institucional_video_url(@institucional_video)
    end

    assert_redirected_to institucional_videos_url
  end
end
