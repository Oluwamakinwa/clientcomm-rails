namespace :setup do
  task :admin_account, [:admin_email, :password] => :environment do |_, args|
    user = AdminUser.find_or_initialize_by(email: args.admin_email)
    user.update!(password: args.password, password_confirmation: args.password)
  end

  task :install_department, [:department_name] => :environment do |_, args|
    unclaimed_user = User.find_by(email: ENV['UNCLAIMED_EMAIL'])

    department = Department.create(
      name: args.department_name,
      phone_number: ENV['TWILIO_PHONE_NUMBER']
    )

    User.all.each do |user|
      user.update!(department: department)
    end

    department.update!(unclaimed_user: unclaimed_user)
  end

  task :migrate_metadata_from_client_to_relationship => :environment do
    Client.all.each do |client|
      client.reporting_relationships.each do |rr|
        rr.active = client.active
        rr.notes = client['notes']
        rr.has_message_error = client.has_message_error
        rr.has_unread_messages = client.has_unread_messages
        rr.client_status_id = client.client_status_id
        rr.save!
      end
    end
  end
end
