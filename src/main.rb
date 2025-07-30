require 'cli-table'
require_relative "#{__dir__}/DB.rb"

DB::INIT()
banner = <<-EOL
====================
= Activity Tracker =
====================
EOL
print(banner)

def main
  stay = true
  while stay do
    puts "\n"
    puts "(1) Do Activity"
    puts "(2) New Activity"
    puts "(3) List Stats"
    puts "(4) Leave"

    print "> "
    input = gets().chomp().to_i
    puts "\n"

    case input
    in 1
      doing()
    in 2
      newAct()
    in 3
      showStats()
    in 4
      stay = false
    else
      puts "Dont recognize that\n\n"
    end
  end
end

def newAct()
  showActs()

  puts "Enter name of new activity"
  puts "Make sure its not already in db"
  print "> "
  name = gets().chomp

  DB::createAct(name)
end

def showActs()
  rows = DB::allActs()

  if rows.empty?
    puts "Please enter an activity first"
    return
  end

  t = Table.new ["id", "Activity"]
  t.rows = rows

  t.show
end

def showStats()
  table = Table.new ["Activty", "Total Time"]
  table.rows = DB::actsWithTime()
  table.rows = table.rows.map{|row| [row[0], secToHM2(row[1])] }
  table.show
end

def doing()
  puts "What do you want to do?"
  puts "Select by id"
  showActs()
  print "> "

  # prevent people from insert wrong thing
  act_id = gets().chomp().to_i

  # the stop thing, does not quite work anymore
  # because of the schema, no start/end time
  puts "Would like to do stopwatch thing (s)"
  puts "Or Insert time manually? (m)"
  print "> "
  choice = gets.chomp
  # check if people insert incorrect thing
  time = 0
  if choice == 'm'
    time = getTime()
    DB::createLog(act_id, nil, nil, time)
  end

  stop = false
  if choice == 's'
    act_start = DB::timeStamp

    seconds = 0
    Thread.new do
      s = ""
      loop do
        s = gets().downcase
        if s.chomp == "q"
          stop = true
          break
        end
      end
    end

    act = DB::actName(act_id)
    until stop do
      puts "#{act}\nEnter (q) to exit, (p) to pause"
      puts "#{ (seconds / 3600).to_s.rjust(2, '0') }:#{ ((seconds / 60) % 60).to_s.rjust(2, '0') }:#{ (seconds % 60).to_s.rjust(2, '0') }"
      sleep(1)
      system("clear") # wont work on windows
      seconds += 1
    end
    # puts "seconds #{seconds} into db"
    time = seconds
    act_end = DB::timeStamp
    DB::createLog(act_id, act_start, act_end, time)
  end


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

main
