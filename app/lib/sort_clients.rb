class SortClients
  def self.clients_list(user:)
    user.clients
        .active
        .order('clients.has_unread_messages DESC, COALESCE(clients.last_contacted_at, clients.created_at) DESC')
  end

  def self.mass_messages_list(user:, selected_clients: [])
    user.clients
        .active
        .sort_by do |c|
          [selected_clients.include?(c.id) ? 1 : 0, (c.last_contacted_at || c.created_at)]
        end.reverse
  end
end
