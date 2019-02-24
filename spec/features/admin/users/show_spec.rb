require 'rails_helper'

RSpec.describe 'admin user show workflow', type: :feature do
  before :each do
    @admin = create(:admin)
    @user = create(:user)
    Address.create(user: @user, nickname: 'nickname', street: 'street', state: 'CO', city: 'Fairfield', zip: 1)

    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@admin)
  end

  it "should show user information" do
    visit admin_user_path(@user)

    expect(page).to have_content("Name: #{@user.name}")
    expect(page).to have_content("Role: #{@user.role}")
    expect(page).to have_content("Email: #{@user.email}")
    expect(page).to have_content("Street: #{@user.addresses.first.street}")
    expect(page).to have_content("City: #{@user.addresses.first.city}")
    expect(page).to have_content("State: #{@user.addresses.first.state}")
    expect(page).to have_content("Zip code: #{@user.addresses.first.zip}")

    expect(page).to_not have_link('See all Orders')
  end

  describe "admin edits user" do
    before(:each) do
      @updated_name = 'Updated Name'
      @updated_email = 'updated_email@example.com'
      @updated_address = 'newest address'
      @updated_city = 'new new york'
      @updated_state = 'S. California'
      @updated_zip = '33333'
      @updated_password = 'newandextrasecure'
    end
    it "should be able to edit any or all user information" do
      old_digest = @user.password_digest
      visit admin_user_path(@user)

      click_link 'Edit'

      fill_in :user_name, with: @updated_name
      fill_in :user_email, with: @updated_email
      fill_in :user_password, with: @updated_password
      fill_in :user_password_confirmation, with: @updated_password

      click_button 'Update User'

      updated_user = User.find_by(email: @updated_email)

      expect(current_path).to eq(admin_user_path(@user))
      expect(page).to have_content("Profile has been updated")
      expect(page).to have_content("Name: #{@updated_name}")
      expect(page).to have_content("Email: #{@updated_email}")
      expect(updated_user.password_digest).to_not eq(old_digest)
    end
  end
end
