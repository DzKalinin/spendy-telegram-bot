class MessageProcessor
  def self.process(message)
    if message.text == '/start'
      MenuBuilder.main_menu(message.from.first_name)
    elsif message.text == '/category_report'
      ReportBuilder.build_for(message.from.username, 'category')
    elsif message.text == '/daily_report'
      ReportBuilder.build_for(message.from.username, 'created_at')
    elsif ExpenseLogger.valid_format?(message)
      ExpenseLogger.log(message)
    else
      MenuBuilder.wrong_format
    end
  end
end
