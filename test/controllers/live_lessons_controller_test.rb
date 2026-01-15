require "test_helper"

class LiveLessonsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @live_lesson = live_lessons(:one)
  end

  test "should get index" do
    get live_lessons_url
    assert_response :success
  end

  test "should get new" do
    get new_live_lesson_url
    assert_response :success
  end

  test "should create live_lesson" do
    assert_difference('LiveLesson.count') do
      post live_lessons_url, params: { live_lesson: { end_date: @live_lesson.end_date, material: @live_lesson.material, start_date: @live_lesson.start_date, status: @live_lesson.status, title: @live_lesson.title, url: @live_lesson.url } }
    end

    assert_redirected_to live_lesson_url(LiveLesson.last)
  end

  test "should show live_lesson" do
    get live_lesson_url(@live_lesson)
    assert_response :success
  end

  test "should get edit" do
    get edit_live_lesson_url(@live_lesson)
    assert_response :success
  end

  test "should update live_lesson" do
    patch live_lesson_url(@live_lesson), params: { live_lesson: { end_date: @live_lesson.end_date, material: @live_lesson.material, start_date: @live_lesson.start_date, status: @live_lesson.status, title: @live_lesson.title, url: @live_lesson.url } }
    assert_redirected_to live_lesson_url(@live_lesson)
  end

  test "should destroy live_lesson" do
    assert_difference('LiveLesson.count', -1) do
      delete live_lesson_url(@live_lesson)
    end

    assert_redirected_to live_lessons_url
  end
end
