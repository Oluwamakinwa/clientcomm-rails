require "rails_helper"
feature 'editing scheduled messages', active_job: true do
  let(:message_body) {'You have an appointment tomorrow at 10am'}
  let(:new_message_body) {'Your appointment tomorrow has been cancelled'}
  let(:userone) { create :user }
  let(:clientone) { create :client, user: userone }
  let(:future_date) { Time.now.tomorrow.change(min: 0) }
  let(:new_future_date) { future_date.tomorrow.change(min: 0) }
  let!(:scheduled_message) { create :message, client: clientone, user: userone, body: message_body, send_at: future_date }

  scenario 'user sends message to client', :js do
    step 'when user logs in' do
      login_as(userone, scope: :user)
    end

    step 'when user goes to messages page' do
      clientone_id = Client.find_by(phone_number: PhoneNumberParser.normalize(clientone.phone_number)).id
      visit client_messages_path(client_id: clientone_id)
      expect(page).to have_content '1 message scheduled'
    end

    step 'when user clicks on scheduled message notice' do
      click_on '1 message scheduled'
      expect(page).to have_css '#scheduled-list-modal', text: 'Manage scheduled messages'
      expect(page).to have_css '#scheduled-list', text: message_body
    end

    step 'when user clicks on edit message' do
      click_on 'Edit'
      expect_edit_modal(future_date, message_body)
    end

    step 'when user edits a message' do

      fill_in 'scheduled_message_body', with: new_message_body

      fill_in 'Date', with: new_future_date.strftime("%m/%d/%Y")
      select new_future_date.strftime("%-l:%M%P"), from: 'Time'

      perform_enqueued_jobs do
        click_on 'Update'
        expect(page).to have_current_path(client_messages_path(scheduled_message.client))
      end
    end

    step 'then when user edits the message again' do
      click_on '1 message scheduled'
      expect(page).to have_css '#scheduled-list-modal', text: 'Manage scheduled messages'
      expect(page).to have_css '#scheduled-list', text: new_message_body

      click_on 'Edit'
      expect_edit_modal(new_future_date, new_message_body)
    end

    step 'when the user clicks the button to dismiss the modal' do
      click_on '×'
      expect(page).to have_no_css '#scheduled-list-modal'
    end

    step 'when user clicks on scheduled message notice' do
      click_on '1 message scheduled'
      expect(page).to have_css '#scheduled-list-modal', text: 'Manage scheduled messages'
      expect(page).to have_css '#scheduled-list', text: new_message_body
    end

    step 'when the user clicks the button to dismiss the modal' do
      click_on '×'
      expect(page).to have_no_css '#scheduled-list-modal'
    end
  end

  def expect_edit_modal(date, message_body)
    expect(page).to have_css '#edit-message-modal', wait: 30
    expect(page).to have_content 'Edit your message'

    expect(page).to have_css '#scheduled_message_body', text: message_body # expect body text field to contain message.body
    expect(page).to have_field('Date', with: date.strftime("%m/%d/%Y"))
    expect(page).to have_select('Time', selected: date.strftime("%-l:%M%P"))
  end
end
