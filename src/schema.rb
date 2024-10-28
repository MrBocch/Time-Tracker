require "sqlite3"
require_relative "#{__dir__}/DB.rb"

def schema()
  db = DB::connect
  db.execute("
    CREATE TABLE IF NOT EXISTS acts(
      act_id   INTEGER PRIMARY KEY AUTOINCREMENT,
      act_name TEXT NOT NULL
    );"
  )

  db.execute("
    CREATE TABLE IF NOT EXISTS log_acts(
      log_id INTEGER PRIMARY KEY AUTOINCREMENT,
      act_id INTEGER NOT NULL,
      act_start TEXT,
      act_end TEXT,
      seconds INTEGER NOT NULL,
      FOREIGN KEY (act_id) REFERENCES acts(act_id)
    );"
  ) # im thinking just calculate manually the seconds that have passed, integer or real number?

  # this is wrong
  db.execute("
  CREATE VIEW IF NOT EXISTS
  total_time_per_activity AS
  SELECT act_name AS Activity, SUM(seconds) AS 'Total Time'
  FROM acts, log_acts
  ;"
  )

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


#sqlite> SELECT act_name AS Activity, SUM(seconds) AS "Total Time"
   #...> FROM acts, log_acts;
