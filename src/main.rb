require 'sqlite3'

def connectDB()
  # i learn this when i made the cli-dict 
  currentDir = __dir__
  db_path = File.join(currentDir, "time.db")
  return SQLite3::Database.open db_path
end

def initDB()
  db = connectDB()
  db.execute("
    CREATE TABLE IF NOT EXISTS act(
      id   INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      time INT 
    );"
  )

  db.close
end

def newAct()
  puts "Enter name of new activity"
  puts "Make sure its not already in db"
  print "> "
  name = gets().chomp

  db = connectDB()
  db.execute("INSERT INTO act (name, time)
              VALUES (?, ?)", [name, 0])

  db.close 
end

# so funny i get to use this from
# my own gist 
# https://gist.github.com/MrBocch/e07e7397005a1c261d77520d7d2a7eee
def getTime
  print "Hours: "
  h = gets.chomp!.to_i
  print "Minutes: "
  m = gets.chomp!.to_i
  print "Seconds: "
  s = gets.chomp!.to_i
  # returns total time in seconds
  return s + (m*60) + (h*3600)
end

def doing()
  puts "What do you want to do?"
  puts "Select by id"

  stats()

  # prevent people from insert wrong thing
  id = gets().chomp().to_i

  # pomodoro thing
  puts "Would like to do pomodoro thing (p)"
  puts "Or Insert time manually? (m)"
  print "> "
  choice = gets.chomp
  time = 0
  # check if people insert incorrect thing
  if choice == 'm'
    time = getTime() 
  end
  if choice == 'p'
    # TODO
  end

  db = connectDB()
  db.execute("UPDATE act 
              SET time = time + #{time}
              WHERE id = #{id};"
  )

end

def secToHM(seconds)
  hours = seconds / 3600
  restm = seconds % 3600
  minutes = restm / 60 
  return hours, minutes
end

def stats()
  db = connectDB()
  rows = db.execute("SELECT * FROM act")
  db.close

  if rows.empty? 
    puts "Please enter an activity first"
    return
  end

  0.upto(rows.length() -1) do |i|
    h, m = secToHM(rows[i][2])
    if h > 0
      rows[i][2] = "#{h} Hours, #{m} Minutes"
    else 
      rows[i][2] = "#{m} Minutes"
    end
  end

  rpad_id = rows.max{|a, b| a[0].to_s.size <=> b[0].to_s.size}[0].to_s.length
  rpad_id = [rpad_id, "id".length].max
  rpad_act = rows.max{|a, b| a[1].size <=> b[1].size}[1].length
  rpad_time = rows.max{|a, b| a[2].size <=> b[2].size}[2].length

  id = "id".ljust(rpad_id, " ")
  activity = "Activity".ljust(rpad_act, " ")
  time = "Time".ljust(rpad_time, " ")
 
  floor = '─'
  wall = '│' 

  id_col = "#{wall} #{id} #{wall}"
  activity_col = "#{activity} #{wall}"
  time_col = "#{time} #{wall}"

  tsign  = {:ut => '┴', :dt => '┬', :rt => '├', :lt => '┤', :cross => '┼'}
  corner = {:tr => '┌', :tl => '┐', :br => '┘', :bl => '└'}
  # this must be the worst code i have ever written in my life
  # sorrow to those that lay their eyes upon it
  uheader = (id_col).split("").map{|c| floor}.join("")
  uheader[0] = corner[:tr]
  uheader[-1] = corner[:tl]

  uheader += (activity_col).split("").map{|c| floor}.join("")
  uheader[id_col.length-1] = tsign[:dt]
  uheader += tsign[:dt]

  uheader += (time_col).split("").map{|c| floor}.join("")
  uheader += corner[:tl]

  dheader = (id_col).split("").map{|c| floor}.join("")
  dheader[0] = tsign[:rt]
  dheader[-1] = tsign[:cross]

  dheader += (activity_col).split("").map{|c| floor}.join("")
  dheader += tsign[:cross]
  
  dheader += (time_col).split("").map{|c| floor}.join("")
  dheader += tsign[:lt]

  endtable = (id_col).split("").map{|c| floor}.join("")
  endtable[0] = corner[:bl]
  endtable[-1] = tsign[:ut]

  endtable += (activity_col).split("").map{|c| floor}.join("")
  endtable += tsign[:ut]

  endtable += (time_col).split("").map{|c| floor}.join("")
  endtable += corner[:br]

  header = "#{id_col} #{activity_col} #{time_col}" 

  # print the top part of table 
  puts uheader 
  puts header
  puts dheader
  # print part of table right below header

  rows.each do |row|
    id = row[0].to_s.ljust(rpad_id, " ")
    act = row[1].ljust(rpad_act, " ") # so cool
    time = row[2].ljust(rpad_time, " ")
    # h, m = secToHM(row[2])

    puts "#{wall} #{id} #{wall} #{act} #{wall} #{time} #{wall}"
  end
  puts endtable

end

initDB()
stay = true 
while stay do 
  puts "\n"
  puts "(1) New Activity"
  puts "(2) List Stats"
  puts "(3) Do Activity"
  puts "(4) Leave"

  print "> "
  input = gets().chomp().to_i
  puts "\n"

  case input  
  in 1
    newAct()
  in 2
    stats()
  in 3
    doing()
  in 4
    stay = false
  else
    puts "Dont recognize that\n\n"

  end
end
