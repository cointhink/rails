Btcmarketwatch::Application.config.middleware.use ExceptionNotifier,
 :email_prefix => SETTINGS["exceptions"]["prefix"],
 :sender_address => SETTINGS["exceptions"]["from"],
 :exception_recipients => SETTINGS["exceptions"]["to"]

