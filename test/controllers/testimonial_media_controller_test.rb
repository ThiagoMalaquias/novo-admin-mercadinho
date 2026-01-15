require "test_helper"

class TestimonialMediaControllerTest < ActionDispatch::IntegrationTest
  setup do
    @testimonial_medium = testimonial_media(:one)
  end

  test "should get index" do
    get testimonial_media_url
    assert_response :success
  end

  test "should get new" do
    get new_testimonial_medium_url
    assert_response :success
  end

  test "should create testimonial_medium" do
    assert_difference('TestimonialMedium.count') do
      post testimonial_media_url, params: { testimonial_medium: { banner: @testimonial_medium.banner, nature: @testimonial_medium.nature, url: @testimonial_medium.url } }
    end

    assert_redirected_to testimonial_medium_url(TestimonialMedium.last)
  end

  test "should show testimonial_medium" do
    get testimonial_medium_url(@testimonial_medium)
    assert_response :success
  end

  test "should get edit" do
    get edit_testimonial_medium_url(@testimonial_medium)
    assert_response :success
  end

  test "should update testimonial_medium" do
    patch testimonial_medium_url(@testimonial_medium), params: { testimonial_medium: { banner: @testimonial_medium.banner, nature: @testimonial_medium.nature, url: @testimonial_medium.url } }
    assert_redirected_to testimonial_medium_url(@testimonial_medium)
  end

  test "should destroy testimonial_medium" do
    assert_difference('TestimonialMedium.count', -1) do
      delete testimonial_medium_url(@testimonial_medium)
    end

    assert_redirected_to testimonial_media_url
  end
end
