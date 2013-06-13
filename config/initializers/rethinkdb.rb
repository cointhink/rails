include RethinkDB::Shortcuts
R = r.connect(SETTINGS["rethinkdb"])
unless r.db_list.run(R).include?(SETTINGS["rethinkdb"]["db"])
  puts "rethinkdb: creating database '#{SETTINGS["rethinkdb"]["db"]}'"
  r.db_create(SETTINGS["rethinkdb"]["db"]).run(R)
  r.table_create('scripts').run(R)
  r.table_create('signals').run(R)
end
