require 'feature_helper'

feature 'viewing a user provile', js: true do
  given!(:user1) do
    create :user,
      email: 'keepmesecret@gmail.com',
      username: 'mypublichandle',
      password: 'nevershowme'
  end
  given!(:user2) do
    create :user,
      username: 'fooColins'
  end
  given!(:trade_request1) do
    create :trade_request, :new_york,
      user: user1,
      name: 'My Trade'
  end
  given!(:trade_request2) do
    create :trade_request, :new_york,
      user: user1,
      name: 'My Trade 2'
  end
  given!(:trade_request3) do
    create :trade_request, :new_york,
      user: user1,
      name: 'My Trade 3'
  end
  given!(:trade_request4) do
    create :trade_request, :new_york,
      user: user2,
      name: "Another Guy's Trade"
  end
  given!(:trade_request5) do
    create :trade_request, :new_york,
      user: user2,
      name: "Another Guy's Trade 2"
  end
  given!(:trade_request6) do
    create :trade_request, :new_york,
      user: user2,
      name: "Another Guy's Trade 3"
  end
  given!(:offer1) do
    create :offer,
      user: user2,
      trade_request: trade_request1,
      status: 'declined'
  end
  given!(:offer2) do
    create :offer,
      user: user2,
      trade_request: trade_request2,
      status: 'pending'
  end
  given!(:offer3) do
    create :offer,
      user: user2,
      trade_request: trade_request3,
      status: 'approved'
  end
  given!(:offer4) do
    create :offer,
      user: user1,
      trade_request: trade_request4,
      status: 'declined'
  end
  given!(:offer5) do
    create :offer,
      user: user1,
      trade_request: trade_request5,
      status: 'pending'
  end
  given!(:offer6) do
    create :offer,
      user: user1,
      trade_request: trade_request6,
      status: 'approved'
  end

  Steps 'I should be able to view the profile page' do
    When 'I visit the profile url' do
      visit '/p/mypublichandle'
    end
    Then 'I should see public information' do
      should_see 'mypublichandle'
    end
    And 'I should not see private information' do
      should_not_see 'keepmesecret'
      should_not_see 'nevershowme'
    end
    And 'I should see the correct number of trades that the user has had' do
      should_see 'Total Trades: 2'
    end
  end

  Steps 'I visit the wrong page' do
    When 'I visit the profile url' do
      visit '/p/typotypo'
    end
    Then 'I should see the 404 page' do
      should_see '404 This page was not found.'
    end
    When 'when I click the link to return to the homepage' do
      click_link 'Return to Homepage'
    end
    Then 'I should be on the homepage' do
      should_see 'Search Results'
      should_be_located root_path
    end
  end

  context 'authenticated' do
    background do
      login_as user2
    end

    Steps 'I find my own profile page' do
      When 'I visit the account page' do
        visit account_index_path
      end
      And 'I click the view my profile button' do
        click_link 'View my Public Profile'
      end
      Then 'I should see public information' do
        should_see 'fooColins'
      end
    end
  end
end