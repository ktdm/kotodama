IO.copy_stream(Rails.root.join("db/seeddata/seed.sqlite3"), Rails.root.join("db/" + Rails.env + ".sqlite3"))
