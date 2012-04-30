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

ActiveRecord::Schema.define(:version => 20120305215730) do

  create_table "editors", :force => true do |t|
    t.integer "mtype"
    t.text    "forms"
    t.text    "script"
  end

  create_table "media", :force => true do |t|
    t.string   "title",                               :null => false
    t.string   "url"
    t.string   "author",     :default => "kotoda.ma"
    t.integer  "count",      :default => 0
    t.text     "info"
    t.integer  "data_id"
    t.string   "data_type"
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
  end

  create_table "mediatypes", :force => true do |t|
    t.text "arguments"
    t.text "script"
  end

  create_table "pages", :force => true do |t|
    t.text "html"
  end

  create_table "users", :force => true do |t|
    t.string   "handle"
    t.string   "url"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

end
