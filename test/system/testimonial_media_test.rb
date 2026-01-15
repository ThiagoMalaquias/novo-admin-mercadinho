require "application_system_test_case"

class TestimonialMediaTest < ApplicationSystemTestCase
  setup do
    @testimonial_medium = testimonial_media(:one)
  end

  test "visiting the index" do
    visit testimonial_media_url
    assert_selector "h1", text: "Testimonial Media"
  end

  test "creating a Testimonial medium" do
    visit testimonial_media_url
    click_on "New Testimonial Medium"

    fill_in "Banner", with: @testimonial_medium.banner
    fill_in "Nature", with: @testimonial_medium.nature
    fill_in "Url", with: @testimonial_medium.url
    click_on "Create Testimonial medium"

    assert_text "Testimonial medium was successfully created"
    click_on "Back"
  end

  test "updating a Testimonial medium" do
    visit testimonial_media_url
    click_on "Edit", match: :first

    fill_in "Banner", with: @testimonial_medium.banner
    fill_in "Nature", with: @testimonial_medium.nature
    fill_in "Url", with: @testimonial_medium.url
    click_on "Update Testimonial medium"

    assert_text "Testimonial medium was successfully updated"
    click_on "Back"
  end

  test "destroying a Testimonial medium" do
    visit testimonial_media_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Testimonial medium was successfully destroyed"
  end
end
