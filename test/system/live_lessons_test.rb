require "application_system_test_case"

class LiveLessonsTest < ApplicationSystemTestCase
  setup do
    @live_lesson = live_lessons(:one)
  end

  test "visiting the index" do
    visit live_lessons_url
    assert_selector "h1", text: "Live Lessons"
  end

  test "creating a Live lesson" do
    visit live_lessons_url
    click_on "New Live Lesson"

    fill_in "End date", with: @live_lesson.end_date
    fill_in "Material", with: @live_lesson.material
    fill_in "Start date", with: @live_lesson.start_date
    fill_in "Status", with: @live_lesson.status
    fill_in "Title", with: @live_lesson.title
    fill_in "Url", with: @live_lesson.url
    click_on "Create Live lesson"

    assert_text "Live lesson was successfully created"
    click_on "Back"
  end

  test "updating a Live lesson" do
    visit live_lessons_url
    click_on "Edit", match: :first

    fill_in "End date", with: @live_lesson.end_date
    fill_in "Material", with: @live_lesson.material
    fill_in "Start date", with: @live_lesson.start_date
    fill_in "Status", with: @live_lesson.status
    fill_in "Title", with: @live_lesson.title
    fill_in "Url", with: @live_lesson.url
    click_on "Update Live lesson"

    assert_text "Live lesson was successfully updated"
    click_on "Back"
  end

  test "destroying a Live lesson" do
    visit live_lessons_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Live lesson was successfully destroyed"
  end
end
