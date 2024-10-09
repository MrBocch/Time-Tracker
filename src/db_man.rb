require "sqlite3"

module DB
  class << self

    def test
      puts "hello world?"
    end

    def connect()
      # i learn this when i made the cli-dict
      currentDir = __dir__
      db_path = File.join(currentDir, "time.db")
      return SQLite3::Database.open db_path
    end

    def initDB()
      db = DB::connect()
      db.execute("
        CREATE TABLE IF NOT EXISTS act(
          id   INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          time INT
        );"
      )

      db.close
    end

    def createAct(name)
      db = DB::connect()
      db.execute("INSERT INTO act (name, time)
                  VALUES (?, ?)", [name, 0])

      db.close
    end

    def getStats()
      db = DB::connect()
      rows = db.execute("SELECT * FROM act")
      db.close
      return rows
    end
  end
end
