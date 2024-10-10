require "sqlite3"

class DB

    def test
      puts "hello world?"
    end

    def self.connect()
      # i learn this when i made the cli-dict
      currentDir = __dir__
      db_path = File.join(currentDir, "time.db")
      return SQLite3::Database.open db_path
    end

    def self.initDB()
      db = self.connect()
      db.execute("
        CREATE TABLE IF NOT EXISTS act(
          id   INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          time INT
        );"
      )

      db.close
    end

    def self.createAct(name)
      db = self.connect()
      db.execute("INSERT INTO act (name, time)
                  VALUES (?, ?)", [name, 0])

      db.close
    end

    def self.getStats()
      db = self.connect()
      rows = db.execute("SELECT * FROM act")
      db.close
      return rows
    end
end
