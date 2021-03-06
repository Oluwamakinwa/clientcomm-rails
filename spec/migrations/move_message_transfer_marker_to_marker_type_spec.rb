require 'rails_helper.rb'
require_relative '../../db/migrate/20180326220423_move_message_transfer_marker_to_marker_type'

describe MoveMessageTransferMarkerToMarkerType do
  let(:user) { create :user }
  let(:client) { create :client, users: [user] }

  after do
    ActiveRecord::Migrator.migrate Rails.root.join('db', 'migrate'), @current_migration
    Message.reset_column_information
  end

  describe '#up' do
    before do
      @current_migration = ActiveRecord::Migrator.current_version
      ActiveRecord::Migrator.migrate Rails.root.join('db', 'migrate'), 20180314000756
      Message.reset_column_information
    end

    subject do
      ActiveRecord::Migrator.migrate Rails.root.join('db', 'migrate'), 20180326220423
      Message.reset_column_information
    end

    it 'messages have proper values on marker_type' do
      rr = ReportingRelationship.find_by(user: user, client: client)

      message_marker = Message.create!(
        reporting_relationship_id: rr.id,
        original_reporting_relationship_id: rr.id,
        transfer_marker: true,
        read: true,
        send_at: Time.zone.now,
        inbound: true,
        number_to: rr.user.department.phone_number,
        number_from: rr.client.phone_number
      )

      message_message = Message.create!(
        reporting_relationship_id: rr.id,
        original_reporting_relationship_id: rr.id,
        transfer_marker: false,
        read: true,
        send_at: Time.zone.now,
        inbound: true,
        number_to: rr.user.department.phone_number,
        number_from: rr.client.phone_number
      )

      subject

      expect(message_message.reload.marker_type).to eq(nil)
      expect(message_marker.reload.marker_type).to eq(TransferMarker.to_s)
    end
  end

  describe '#down' do
    before do
      @current_migration = ActiveRecord::Migrator.current_version
      ActiveRecord::Migrator.migrate Rails.root.join('db', 'migrate'), 20180326220423
      Message.reset_column_information
    end

    subject do
      ActiveRecord::Migrator.migrate Rails.root.join('db', 'migrate'), 20180314000756
      Message.reset_column_information
    end

    it 'messages have proper values on transfer_marker' do
      rr = ReportingRelationship.find_by(user: user, client: client)

      message_marker = Message.create!(
        reporting_relationship_id: rr.id,
        original_reporting_relationship_id: rr.id,
        marker_type: TransferMarker.to_s,
        read: true,
        send_at: Time.zone.now,
        inbound: true,
        number_to: rr.user.department.phone_number,
        number_from: rr.client.phone_number
      )

      message_message = Message.create!(
        reporting_relationship_id: rr.id,
        original_reporting_relationship_id: rr.id,
        marker_type: nil,
        read: true,
        send_at: Time.zone.now,
        inbound: true,
        number_to: rr.user.department.phone_number,
        number_from: rr.client.phone_number
      )

      subject

      expect(message_message.reload.transfer_marker).to eq(false)
      expect(message_marker.reload.transfer_marker).to eq(true)
    end
  end
end
