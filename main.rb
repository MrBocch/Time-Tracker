require 'sqlite3'

# idk what should i do
# always be connected to 
# db, or only connect when need 2
# then disconnect when no longer needed 
def newAct()
  db = SQLite3::Database.open "time.db"
  db.execute <<-SQL
    CREATE TABLE IF NOT EXISTS act(
      id   INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      time INT 
    );
  SQL
  
  puts "Enter name of new activity"
  puts "Make sure its not already in db"
  print "> "
  name = gets().chomp

  db.execute("INSERT INTO act (name, time)
              VALUES (?, ?)", [name, 0])

  db.close 
end

def doing()
  db = SQLite3::Database.open "time.db"

  puts "What do you want to do?"
  puts "Select by id"

  stats()
  db.close

  # prevent people from insert wrong thing
  id = gets().chomp().to_i

  # pomodoro thing
  puts "Insert time in seconds"
  time = gets().chomp().to_i
  db = SQLite3::Database.open "time.db"

  # check if table exists
  db.execute("UPDATE act 
              SET time = time + #{time}
              WHERE id = #{id};"
  )

end

def stats()
  db = SQLite3::Database.open "time.db"
  # how to check if table exist?
  puts "id | Activity | Time in Seconds"
  # i want to print stats in H:M:S
  db.execute("SELECT * FROM act") do |row|
    p row
  end

  db.close
end


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
    return 
  else
    puts "Dont recognize that\n\n"

  end
end
