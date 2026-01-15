require "application_system_test_case"

class InstitucionalVideosTest < ApplicationSystemTestCase
  setup do
    @institucional_video = institucional_videos(:one)
  end

  test "visiting the index" do
    visit institucional_videos_url
    assert_selector "h1", text: "Institucional Videos"
  end

  test "creating a Institucional video" do
    visit institucional_videos_url
    click_on "New Institucional Video"

    fill_in "Company", with: @institucional_video.company_id
    fill_in "Url", with: @institucional_video.url
    click_on "Create Institucional video"

    assert_text "Institucional video was successfully created"
    click_on "Back"
  end

  test "updating a Institucional video" do
    visit institucional_videos_url
    click_on "Edit", match: :first

    fill_in "Company", with: @institucional_video.company_id
    fill_in "Url", with: @institucional_video.url
    click_on "Update Institucional video"

    assert_text "Institucional video was successfully updated"
    click_on "Back"
  end

  test "destroying a Institucional video" do
    visit institucional_videos_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Institucional video was successfully destroyed"
  end
end
