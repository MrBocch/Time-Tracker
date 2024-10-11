require "sqlite3"

# im thinking it would just run all the code
# to create the database if it does not exist

def connect()
  currentDir = __dir__
  db_path = File.join(currentDir, "test.db")
  return SQLite3::Database.open db_path
end


def initDB()
  db = connect()
  db.execute("
    CREATE TABLE IF NOT EXISTS acts(
      act_id   INTEGER PRIMARY KEY AUTOINCREMENT,
      act_name TEXT NOT NULL
    );"
  )

  # i need to really sit down and think how
  # to design this table, other wise it going to be a pain in the future

  db.close
end

def testtime
  db = connect()
  start_act = db.execute("
    SELECT datetime(CURRENT_TIMESTAMP, 'localtime');;
    ")

  p start_act
end

initDB
testtime
