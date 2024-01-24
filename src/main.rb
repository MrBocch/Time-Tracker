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

  # make into a map :floor => ?
  floor = '─'
  wall = '│'
  cross = '┼'
  downt = '┬'
  rt = '├' 
  lt = '┤'
  upt = '┴'
  urightcorner = '┌'
  brightcorner = '└'
  uleftcorner = '┐'
  bleftcorner = '┘'

  rpad = rows.max{|a, b| a[1].size <=> b[1].size}[1].length

  id = "id".ljust(3, " ")
  activity = "Activity".ljust(rpad, " ")

  header = "#{id} #{wall} #{activity} #{wall} Time"
  # this wont work i have to insert the cross piece
  lines = header.split("").map{|c| floor}.join("")

  puts header

  rows.each do |row|
    id = row[0].to_s.ljust(3, " ")
    act = row[1].ljust(rpad, " ") # so cool
    h, m = secToHM(row[2])

    # repeating my self alittle 
    if h > 0
      puts "#{id} #{wall} #{act} #{wall} #{h} Hours, #{m} Minutes"
    else 
      puts "#{id} #{wall} #{act} #{wall} #{m} Minutes"
    end
  end

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