include RethinkDB::Shortcuts
r.connect(SETTINGS["rethinkdb"]["host"],SETTINGS["rethinkdb"]["port"],SETTINGS["rethinkdb"]["db"]).repl
unless r.db_list.run.include?(SETTINGS["rethinkdb"]["db"])
  puts "rethinkdb: creating database '#{SETTINGS["rethinkdb"]["db"]}'"
  r.db_create(SETTINGS["rethinkdb"]["db"]).run
  r.table_create('scripts').run
end
