module ClientStatusHelper
  def client_statuses(user:)
    output = {}

    ClientStatus.all.map do |status|
      followup_date = Time.now - status.followup_date.days
      found_clients = user.clients
                        .where(active: true)
                        .where(client_status: status)
                        .where('last_contacted_at < ?', followup_date)

      output[status.name] = found_clients.pluck(:id) if found_clients.present?
    end

    output
  end
end
