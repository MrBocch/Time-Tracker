require 'sqlite3'
require 'cli-table'

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

def stats()
  db = connectDB()
  rows = db.execute("SELECT * FROM act")
  db.close

  if rows.empty?
    puts "Please enter an activity first"
    return
  end

  t = Table.new ["id", "Activity", "Time"]
  t.data = []
  rows.each do |l|
    temp = l[0..1]
    temp << secToHM2(l[2])
    if temp != nil then t.data << temp end
  end

  t.printTable

end

def doing()
  puts "What do you want to do?"
  puts "Select by id"

  stats()

  # prevent people from insert wrong thing
  id = gets().chomp().to_i

  # pomodoro thing
  puts "Would like to do stopwatch thing (s)"
  puts "Or Insert time manually? (m)"
  print "> "
  choice = gets.chomp
  # check if people insert incorrect thing
  time = 0
  if choice == 'm'
    time = getTime()
  end

  stop = false
  if choice == 's'
    seconds = 0
    Thread.new do
      s = ""
      loop do
        s = gets()
        if s.chomp == "q"
          stop = true
          break
        end
      end
    end
    until stop do
      puts "Enter (q) to exit"
      puts "#{seconds / 3600}:#{seconds / 60}:#{seconds % 60}"
      sleep(1)
      system("clear") # wont work on windows
      seconds += 1
    end
    # puts "seconds #{seconds} into db"
    time = seconds
  end

  db = connectDB()
  db.execute("UPDATE act
              SET time = time + #{time}
              WHERE id = #{id};"
  )

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

def secToHM(seconds)
  hours = seconds / 3600
  restm = seconds % 3600
  minutes = restm / 60
  return hours, minutes
end

def secToHM2(seconds)
  hours, minutes = secToHM(seconds)

  if hours == 0
    return "#{minutes} Minutes"
  else
    hs = ""
    if hours == 1 then hs = "Hour" else hs = "Hours" end
    return "#{hours} #{hs}, #{minutes} Minutes"
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
