# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130607162035) do

  create_table "acl_flags", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "authorizations", :force => true do |t|
    t.integer  "acl_flag_id"
    t.integer  "user_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "balances", :force => true do |t|
    t.string   "currency"
    t.decimal  "amount"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.integer  "balanceable_id"
    t.string   "balanceable_type"
  end

  add_index "balances", ["balanceable_id"], :name => "index_balances_on_balanceable_id"
  add_index "balances", ["balanceable_type"], :name => "index_balances_on_balanceable_type"

  create_table "depth_runs", :force => true do |t|
    t.integer  "market_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.integer  "exchange_run_id"
    t.integer  "best_offer_id"
    t.integer  "cost_id"
  end

  add_index "depth_runs", ["exchange_run_id"], :name => "index_depth_runs_on_exchange_run_id"
  add_index "depth_runs", ["market_id"], :name => "index_depth_runs_on_market_id"

  create_table "exchange_balances", :force => true do |t|
    t.integer  "strategy_id"
    t.integer  "exchange_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "exchange_balances", ["exchange_id"], :name => "index_exchange_balances_on_exchange_id"
  add_index "exchange_balances", ["strategy_id"], :name => "index_exchange_balances_on_strategy_id"

  create_table "exchange_runs", :force => true do |t|
    t.integer  "exchange_id"
    t.integer  "snapshot_id"
    t.integer  "duration_ms"
    t.datetime "start_at"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "exchange_runs", ["exchange_id"], :name => "index_exchange_runs_on_exchange_id"
  add_index "exchange_runs", ["snapshot_id"], :name => "index_exchange_runs_on_snapshot_id"

  create_table "exchanges", :force => true do |t|
    t.string   "name"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.string   "country_code"
    t.boolean  "active"
    t.string   "slug"
    t.string   "logo_url"
    t.string   "url"
    t.string   "display_name"
  end

  add_index "exchanges", ["slug"], :name => "index_exchanges_on_slug", :unique => true

  create_table "markets", :force => true do |t|
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.integer  "exchange_id"
    t.integer  "from_exchange_id"
    t.string   "from_currency"
    t.integer  "to_exchange_id"
    t.string   "to_currency"
    t.decimal  "fee_percentage"
    t.integer  "delay_ms"
  end

  add_index "markets", ["exchange_id"], :name => "index_markets_on_exchange_id"
  add_index "markets", ["from_exchange_id"], :name => "index_markets_on_from_exchange_id"
  add_index "markets", ["to_exchange_id"], :name => "index_markets_on_to_exchange_id"

  create_table "notes", :force => true do |t|
    t.string   "text"
    t.integer  "notable_id"
    t.string   "notable_type"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.string   "category"
  end

  create_table "offers", :force => true do |t|
    t.datetime "listed_at"
    t.string   "bidask"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.integer  "depth_run_id"
    t.decimal  "price"
    t.decimal  "quantity"
    t.string   "currency"
    t.integer  "market_id"
  end

  add_index "offers", ["depth_run_id", "price"], :name => "index_offers_on_depth_run_id_and_price"
  add_index "offers", ["depth_run_id"], :name => "index_offers_on_depth_run_id"
  add_index "offers", ["market_id"], :name => "index_offers_on_market_id"

  create_table "script_runs", :force => true do |t|
    t.integer  "script_id"
    t.string   "json_output"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "scripts", :force => true do |t|
    t.string   "name"
    t.string   "body_url"
    t.integer  "user_id"
    t.string   "slug"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
    t.boolean  "deleted"
    t.text     "body"
    t.string   "docker_host"
    t.string   "docker_container_id"
  end

  add_index "scripts", ["slug"], :name => "index_scripts_on_slug", :unique => true

  create_table "snapshots", :force => true do |t|
    t.integer  "strategy_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "snapshots", ["strategy_id"], :name => "index_snapshots_on_strategy_id"

  create_table "stages", :force => true do |t|
    t.integer  "sequence"
    t.integer  "strategy_id"
    t.integer  "balance_in_id"
    t.integer  "balance_out_id"
    t.integer  "potential_id"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
    t.integer  "parent_id"
    t.boolean  "children_concurrent"
    t.string   "name"
  end

  add_index "stages", ["balance_in_id"], :name => "index_stages_on_balance_in_id"
  add_index "stages", ["balance_out_id"], :name => "index_stages_on_balance_out_id"
  add_index "stages", ["potential_id"], :name => "index_stages_on_potential_id"
  add_index "stages", ["strategy_id"], :name => "index_stages_on_strategy_id"

  create_table "strategies", :force => true do |t|
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.integer  "balance_in_id"
    t.integer  "balance_out_id"
    t.integer  "potential_id"
  end

  add_index "strategies", ["balance_in_id"], :name => "index_strategies_on_balance_in_id"
  add_index "strategies", ["balance_out_id"], :name => "index_strategies_on_balance_out_id"
  add_index "strategies", ["potential_id"], :name => "index_strategies_on_potential_id"

  create_table "tickers", :force => true do |t|
    t.integer  "market_id"
    t.decimal  "highest_bid_usd"
    t.decimal  "lowest_ask_usd"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "tickers", ["market_id"], :name => "index_tickers_on_market_id"

  create_table "trades", :force => true do |t|
    t.decimal  "expected_fee"
    t.decimal  "fee"
    t.decimal  "rate"
    t.boolean  "executed"
    t.string   "order_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.integer  "balance_in_id"
    t.integer  "balance_out_id"
    t.integer  "offer_id"
    t.integer  "stage_id"
  end

  add_index "trades", ["balance_in_id"], :name => "index_trades_on_balance_in_id"
  add_index "trades", ["balance_out_id"], :name => "index_trades_on_balance_out_id"
  add_index "trades", ["offer_id"], :name => "index_trades_on_offer_id"
  add_index "trades", ["stage_id"], :name => "index_trades_on_stage_id"

  create_table "users", :force => true do |t|
    t.string   "username"
    t.string   "email"
    t.string   "encrypted_password"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.string   "slug"
  end

end
