class AppLogger
  def self.info(msg)
    puts msg if Settings.development?
    logger.info(msg)
  end

  private

  def self.logger
    @logger ||= Logger.new('logs/bot.log', 7, 1024 * 50)
  end
end
