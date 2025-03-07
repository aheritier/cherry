require 'application_system_test_case'

class OnboardingTest < ApplicationSystemTestCase
  let!(:user) { create(:user, name: 'Flavio Wuensche', github_handle: 'fwuensche') }

  it 'goes through onboarding' do
    sign_in user
    find('a', text: 'Projects').click
    assert_text 'Create a new project'

    click_on 'Avatar'
    find('li', text: 'Authorizations').click
    assert_text 'Authorizations'
    assert_text 'You first need to create a project'

    project = create(:project, user: user, name: 'rails/rails')
    visit user_projects_path
    find('tr', text: 'rails/rails').click
    assert_text 'Fill up your project with historic data by running the following command'

    create(:report, metric: create(:metric, project: project, name: 'rubocop'), value: 12, date: Time.current)
    refresh
    find('a', text: 'Projects').click
    find('tr', text: 'rails/rails').click
    find('tr', text: 'rubocop').click

    assert_text 'Contributions'
    assert_text 'You can start tracking your contributions by running'
    assert_text 'Occurrences (0)'
  end
end
