class ReportBuilder
  class << self
    def build_for(user_name, agg_field)
      begin
        reporting_response = agg_spend_by(agg_field, user_name)
        spends = JSON.parse(reporting_response.body)['spends']
        if spends.empty?
          'No expenses in this month!'
        else
          spends.each_with_object('') do |spend_hash, msg|
            msg << "#{spend_hash['agg_field_value']}: #{spend_hash['amount']} #{spend_hash['currency']} | operations count: #{spend_hash['expenses_count']}\n"
          end.strip
        end
      rescue Exception => ex
        "Cannot generate report: #{ex.message}"
      end
    end

    private

    def agg_spend_by(agg_field, user_name)
      case agg_field
      when 'category'
        spend_by_category_for(user_name)
      when 'created_at'
        spend_by_day_for(user_name)
      else
        raise ArgumentError.new("Unsupported aggregation: #{agg_field}!")
      end
    end

    def spend_by_category_for(user_name)
      _agg_spend_for(user_name, 'spend_by_category')
    end

    def spend_by_day_for(user_name)
      _agg_spend_for(user_name, 'spend_by_day')
    end

    def _agg_spend_for(user_name, endpoint)
      url = "#{Settings.app[:spendy_reporting_url]}#{endpoint}?user_name=#{user_name}&start_date=#{start_date}&end_date=#{end_date}"
      AppLogger.info("GET: #{url}")
      RestClient.get(url)
    end

    def start_date
      Time.zone.now.beginning_of_month.to_date
    end

    def end_date
      Time.zone.now.end_of_day.to_date
    end
  end
end
