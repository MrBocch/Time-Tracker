require "sqlite3"

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
  ").flatten[0]

  sleep(3)

  end_act = db.execute("
      SELECT datetime(CURRENT_TIMESTAMP, 'localtime');;
  ").flatten[0]

  p start_act
  p end_act
  #SELECT (julianday('final_time') - julianday('initial_time')) * 24 * 60 AS minutes_difference;

  tx = db.execute("
      SELECT (julianday(?) - julianday(?)) * 24 * 60 * 60 AS seconds_passed;
  ", [end_act, start_act])

  p tx
end

initDB
testtime
"2024-10-11 13:59:15"
"2024-10-11 13:59:18"
