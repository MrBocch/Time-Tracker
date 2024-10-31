require "sqlite3"
require_relative "#{__dir__}/schema.rb"

class DB

    def self.connect()
      # i learn this when i made the cli-dict
      currentDir = __dir__
      db_path = File.join(currentDir, "logs/time.db")
      # db_path = File.join(currentDir, "test.db")
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

    def self.createLog(id, act_start, act_end, seconds)
      db = self.connect()
      db.execute("
        INSERT INTO log_acts (act_id, act_start, act_end, seconds)
        VALUES (?, ?, ?, ?);
        ", [id, act_start, act_end, seconds])
    end

    def self.timeStamp()
      db = self.connect()
      stamp = db.execute("
          SELECT datetime(CURRENT_TIMESTAMP, 'localtime');;
      ").flatten[0]

      return stamp
    end

    def self.allActs()
      db = self.connect()
      rows = db.execute("SELECT * FROM acts")
      db.close
      return rows
    end

    def self.actsWithTime()
        db = self.connect()
        # i dont understand this, wtf is a, la ?
        rows = db.execute("
          SELECT
              a.act_name,
              COALESCE(SUM(la.seconds), 0) AS total_time
          FROM
              acts a
          LEFT JOIN
              log_acts la ON a.act_id = la.act_id
          GROUP BY
              a.act_id
        ;")
        # with if an activity is not in the act_log?
        db.close
        return rows
    end

end
