require 'rails_helper'
require 'rake'

describe 'utils rake tasks' do
  before do
    Rake.application.rake_require 'tasks/utils'
    Rake::Task.define_task(:environment)
  end

  describe 'utils:get_status', type: :request do
    subject { Rake::Task['utils:get_status'].invoke(*sids) }

    context 'no sids are passed' do
      let(:sids) { [] }

      it 'outputs an error with instructions' do
        expect { subject }.to output(/no Twilio SIDs passed/).to_stdout
      end
    end

    context 'the message exists' do
      let(:message) { create :text_message, twilio_status: 'delivered', inbound: false, read: true }
      let(:sids) { [message.twilio_sid] }

      it 'outputs the status of the message' do
        expected_output = <<~OUTPUT
          getting statuses for 1 Twilio SIDs
          ==================================
              sid: #{message.twilio_sid}
           status: ✅ DELIVERED
          inbound:    false 📤
             read: 📭 true
          ----------

          0 SIDs not found
        OUTPUT

        expect { subject }.to output(expected_output).to_stdout
      end
    end

    context 'the message does not exist' do
      let(:bad_sid) { SecureRandom.hex(17) }
      let(:sids) { [bad_sid] }

      it 'outputs an error message' do
        expected_output = <<~OUTPUT
          getting statuses for 1 Twilio SIDs
          ==================================
          🔥 !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! 🔥
          🔥 #{bad_sid} WAS NOT FOUND 🔥
          🔥 !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! 🔥
          ----------

          1 SIDs not found
          ----------
          '#{bad_sid}'
          ----------
          #{bad_sid}
          ----------
          #{bad_sid}
        OUTPUT

        expect { subject }.to output(expected_output).to_stdout
      end
    end

    context 'the sid represents a telephone call' do
      let(:voice_sid) { "CA#{SecureRandom.hex(15)}" }
      let(:sids) { [voice_sid] }

      it 'outputs an error message' do
        expected_output = <<~OUTPUT
          getting statuses for 1 Twilio SIDs
          ==================================
          📞 !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! 📞
          📞 #{voice_sid} IS PHONE CALL 📞
          📞 !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! 📞
          ----------

          1 SIDs not found
          ----------
          '#{voice_sid}'
          ----------
          #{voice_sid}
          ----------
          #{voice_sid}
        OUTPUT

        expect { subject }.to output(expected_output).to_stdout
      end
    end

    context 'multiple messages exist' do
      let(:message_one) { create :text_message, twilio_status: 'undelivered', inbound: false, read: true }
      let(:message_two) { create :text_message, twilio_status: 'sent', inbound: false, read: true }
      let(:message_three) { create :text_message, twilio_status: 'received', inbound: true, read: false }
      let(:sids) { [message_one.twilio_sid, message_two.twilio_sid, message_three.twilio_sid] }

      it 'outputs the status of the message' do
        expected_output = <<~OUTPUT
          getting statuses for 3 Twilio SIDs
          ==================================
              sid: #{message_one.twilio_sid}
           status: ❌ UNDELIVERED
          inbound:    false 📤
             read: 📭 true
          ----------
              sid: #{message_two.twilio_sid}
           status: 🤔 SENT
          inbound:    false 📤
             read: 📭 true
          ----------
              sid: #{message_three.twilio_sid}
           status: ✅ RECEIVED
          inbound: 📥 true
             read:    false 📬
          ----------

          0 SIDs not found
        OUTPUT

        expect { subject }.to output(expected_output).to_stdout
      end
    end
  end
end
