require 'net/http'
require 'json'
# RIJjudcDGcIB2uxvcyywsG2AISGVZLrZOJRWjScc API TOKEN NOT TO LOSE
# API Token was sadly not useful when using net/http library

def read_tickets()
  url = "https://pdsworkshop.zendesk.com/api/v2/tickets.json"
  puts("Hello world")
  uri = URI(url)

  request = Net::HTTP::Get.new(uri)
  request.basic_auth 'pdgeorge.geekpride@gmail.com', 'PASSWORD_GOES_HERE'

  response = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => uri.scheme == "https", :verify_mode => OpenSSL::SSL::VERIFY_NONE) {|http|
    http.request(request)
  }
  return response
end

def display_all(all)
  i = 0
  continue = 0
  for i in 0...all["tickets"].length
      puts("The ID of the #{i}th item is: #{all["tickets"][i]["id"]}")
      puts("The Subject of the #{i}th item is: #{all["tickets"][i]["subject"]}")
    if(i%25 == 0 && i != 0)
      puts("================================================================================")
      puts("Press Enter To Get The Next Page Of 25")
      puts("================================================================================")
      STDOUT.flush
      gets()
    end
  end
end

def display_single(all)
  puts("Under construction, please come back soon")
end

def search_ticket(all)
  begin
    puts("Please make a choice between 1 and 9")
    puts("Enter 1 to search subjects.")
    puts("Enter 2 to search descriptions.")
    puts("Enter 3 to search tags.")
    puts("Enter 4 to search requester id.")
    puts("Enter 5 to search assignee id.")
    STDOUT.flush
    choice = gets.chomp().to_i
  end while (!(1..5).member?(choice))
  case choice
  when 1
    search_string(all, "description")
  end
end

def search_integer(all, specific)
  puts("Tell me what you want to find please")
  STDOUT.flush
  search = gets.chomp.to_i
  for i in 0...all["tickets"].length
    puts(all["tickets"][i][specific])
    puts(all["tickets"][i][specific]) if all["tickets"][i][specific] == search
  end
end

def search_string(all, specific)
  puts("Tell me what you want to find please")
  STDOUT.flush
  search = gets.chomp
  for i in 0...all["tickets"].length
    # puts(all["tickets"][i][specific])
    puts(all["tickets"][i][specific]) if all["tickets"][i][specific].include? search
    puts(all["tickets"][i]["subject"]) if all["tickets"][i][specific].include? search
    puts("================================================================================") if all["tickets"][i][specific].include? search
  end
end


def main_menu()
  tickets = read_tickets()
  parsed = JSON.parse(tickets.body)
  begin
    puts("Please make a choice between 1 and 3")
    puts("Enter 1 to view all tickets.")
    puts("Enter 2 to view a specific ticket")
    puts("Enter 3 to search tickets")
    STDOUT.flush
    choice = gets.chomp().to_i
  end while (!(1..3).member?(choice))
  case choice
  when 1
    display_all(parsed)
  when 2
    display_single(parsed)
  when 3
    search_ticket(parsed)
  else
    puts("How did you get here?")
  end
end

def main()
  main_menu()
end

main()
