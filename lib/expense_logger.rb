class ExpenseLogger
  AVAILABLE_EXPENSE_SIZES = [3, 4].to_set.freeze

  def self.valid_format?(message)
    AVAILABLE_EXPENSE_SIZES.include?(message.text.split(';').count)
  end

  def self.log(message)
    amount, currency, category, place = message.text.split(';')
    event = { user_name: message.from.username,
              amount: amount,
              currency: currency,
              category: category,
              place: place }
    response = push_to_spendy_events_processor(event)
    JSON.parse(response.body)['message'] rescue 'Event cannot be processed'
  end

  private

  def self.push_to_spendy_events_processor(event)
    AppLogger.info("POST: #{Settings.app[:google_cloud_function_url]}, PAYLOAD: #{{ spend_event: event}.inspect}, HEADERS: #{{ context_type: :json }}")
    RestClient.post(Settings.app[:google_cloud_function_url], { spend_event: event }.to_json, { context_type: :json })
  end
end
