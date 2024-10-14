require "sqlite3"
require_relative "#{__dir__}/schema.rb"

class DB

    def self.connect()
      # i learn this when i made the cli-dict
      currentDir = __dir__
      #db_path = File.join(currentDir, "time.db")
      db_path = File.join(currentDir, "test.db")
      return SQLite3::Database.open db_path
    end

    def self.INIT()
      schema()
    end

    def self.createAct(name)
      db = self.connect()
      db.execute("INSERT INTO acts (act_name)
                  VALUES (?)", [name])

      db.close
    end

    def self.allActs()
      db = self.connect()
      rows = db.execute("SELECT * FROM acts")
      db.close
      return rows
    end
end
