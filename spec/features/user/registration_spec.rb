require 'rails_helper'

RSpec.describe 'User Registration', type: :feature do
  before :each do
    @name = 'Megan'
    @address = '310 Riverside Dr'
    @city = 'Fairfield'
    @state = 'OK'
    @zip = 52565
    @email = 'megan@example.com'
    @password = 'supersecurepassword'
  end
  it 'should have form that creates new user' do
    visit registration_path

    fill_in :user_name, with: @name
    fill_in :user_email, with: @email
    fill_in :user_password, with: @password
    fill_in :user_password_confirmation, with: @password

    click_on 'Create User'

    expect(page).to have_content("Welcome #{@name}, you are now registered and logged in.")
    expect(page).to have_content("Enter a home address.")

    fill_in :address_street, with: @address
    fill_in :address_city, with: @city
    fill_in :address_state, with: @state
    fill_in :address_zip, with: @zip

    click_on 'Create Address'

    new_user = User.last

    expect(current_path).to eq(profile_path)
    expect(new_user.name).to eq(@name)
    expect(new_user.email).to eq(@email)
    expect(new_user.addresses.first.city).to eq(@city)
    expect(new_user.addresses.first.street).to eq(@address)
    expect(new_user.addresses.first.state).to eq(@state)
    expect(new_user.addresses.first.zip).to eq(@zip)
  end

  it 'renders new form and flash alert if required fields are missing' do
    visit registration_path

    click_on 'Create User'

    expect(page).to have_content("Required field(s) missing.")

    expect(page).to have_content("3 errors prohibited this user from being saved")
    expect(page).to have_content("Password can't be blank")
    expect(page).to have_content("Name can't be blank")
    expect(page).to have_content("Email can't be blank")
  end

  it 'renders new form and flash alert if not all information is provided but re-populates fields' do
    visit registration_path

    fill_in :user_name, with: @name
    fill_in :user_password, with: @password
    fill_in :user_password_confirmation, with: @password

    click_on 'Create User'

    expect(find_field('Name').value).to eq(@name)
  end

  it 'renders new form and flash alert if email already exists' do
    user = create(:user, email: @email)

    visit registration_path

    fill_in :user_name, with: @name
    fill_in :user_email, with: user.email
    fill_in :user_password, with: @password
    fill_in :user_password_confirmation, with: @password

    click_on 'Create User'

    expect(page).to have_content("Email has already been taken")
    expect(find_field('Name').value).to eq(@name)
    expect(find_field('Email').value).to eq('')
  end
end
