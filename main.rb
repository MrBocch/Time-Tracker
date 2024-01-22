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

def stats()
  puts "id | Activity | Time in Seconds"
  # i want to print stats in H:M:S
  db = connectDB()
  db.execute("SELECT * FROM act") do |row|
    p row
  end

  db.close
end

initDB()
stay = true 
while stay do 
  puts "(1) New Activity"
  puts "(2) List Stats"
  puts "(3) Do Activity"
  puts "(4) Leave"

  print "> "
  input = gets().chomp().to_i

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
