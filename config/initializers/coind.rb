COIND = {}
SETTINGS["cryptocoins"].keys.map do |coin|
  COIND[coin] = Jimson::Client.new(SETTINGS["cryptocoins"][coin]["url"], {:timeout => 1}) 
end
