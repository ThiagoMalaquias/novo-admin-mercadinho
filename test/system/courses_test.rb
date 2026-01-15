require "application_system_test_case"

class CoursesTest < ApplicationSystemTestCase
  setup do
    @course = courses(:one)
  end

  test "visiting the index" do
    visit courses_url
    assert_selector "h1", text: "Courses"
  end

  test "creating a Course" do
    visit courses_url
    click_on "New Course"

    fill_in "Category", with: @course.category_id
    fill_in "Description", with: @course.description
    fill_in "Duration", with: @course.duration
    fill_in "Featured", with: @course.featured
    fill_in "Installments", with: @course.installments
    fill_in "Slug", with: @course.slug
    fill_in "Status access", with: @course.status_access
    fill_in "Status disclosure", with: @course.status_disclosure
    fill_in "Supplementary material", with: @course.supplementary_material
    fill_in "Title", with: @course.title
    fill_in "Vacancies", with: @course.vacancies
    fill_in "Value cash", with: @course.value_cash
    fill_in "Value installment", with: @course.value_installment
    fill_in "Value of", with: @course.value_of
    click_on "Create Course"

    assert_text "Course was successfully created"
    click_on "Back"
  end

  test "updating a Course" do
    visit courses_url
    click_on "Edit", match: :first

    fill_in "Category", with: @course.category_id
    fill_in "Description", with: @course.description
    fill_in "Duration", with: @course.duration
    fill_in "Featured", with: @course.featured
    fill_in "Installments", with: @course.installments
    fill_in "Slug", with: @course.slug
    fill_in "Status access", with: @course.status_access
    fill_in "Status disclosure", with: @course.status_disclosure
    fill_in "Supplementary material", with: @course.supplementary_material
    fill_in "Title", with: @course.title
    fill_in "Vacancies", with: @course.vacancies
    fill_in "Value cash", with: @course.value_cash
    fill_in "Value installment", with: @course.value_installment
    fill_in "Value of", with: @course.value_of
    click_on "Update Course"

    assert_text "Course was successfully updated"
    click_on "Back"
  end

  test "destroying a Course" do
    visit courses_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Course was successfully destroyed"
  end
end
