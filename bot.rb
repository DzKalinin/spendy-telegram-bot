require './app.rb'

Telegram::Bot::Client.run(Settings.app[:telegram_token]) do |bot|
  AppLogger.info("Started!")
  bot.listen do |message|
    respond_to_channel = -> (bot, message, response_message) do
      AppLogger.info("#{message.from.username} - #{response_message}")
      bot.api.send_message(chat_id: message.chat.id, text: response_message)
    end
    begin
      respond_to_channel.call(bot, message, MessageProcessor.process(message))
    rescue Exception => ex
      respond_to_channel.call(bot, message, ex.message)
    end
  end
end
