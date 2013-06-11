COIND = {}
SETTINGS["cryptocoins"].keys.map do |coin|
  COIND[coin] = Jimson::Client.new(SETTINGS["cryptocoins"][coin]["url"])
end
