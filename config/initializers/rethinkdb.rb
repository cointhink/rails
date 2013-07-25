include RethinkDB::Shortcuts
R = r.connect(:host => SETTINGS["rethinkdb"]["host"],
              :port => SETTINGS["rethinkdb"]["port"],
              :db => SETTINGS["rethinkdb"]["db"])
unless r.db_list.run(R).include?(SETTINGS["rethinkdb"]["db"])
  puts "rethinkdb: creating database '#{SETTINGS["rethinkdb"]["db"]}'"
  r.db_create(SETTINGS["rethinkdb"]["db"]).run(R)
  r.table_create('scripts').run(R)
  r.table_create('storage', {primary_key:'_cointhink_id_'}).run(R)
  r.table_create('signals').run(R)
  r.table('signals').index_create('name').run(R)
end
