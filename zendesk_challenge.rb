require 'net/http'
require 'json'
# RIJjudcDGcIB2uxvcyywsG2AISGVZLrZOJRWjScc API TOKEN NOT TO LOSE
# API Token was sadly not useful when using net/http library

def read_tickets()
  url = "https://pdsworkshop.zendesk.com/api/v2/tickets.json"
  puts("Hello world")
  uri = URI(url)

  request = Net::HTTP::Get.new(uri)
  request.basic_auth 'pdgeorge.geekpride@gmail.com', 'Zendeskwolf236'

  response = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => uri.scheme == "https", :verify_mode => OpenSSL::SSL::VERIFY_NONE) {|http|
    http.request(request)
  }
  return response
end

def pager(x)
  if(x % 25 == 0 && x != 0)
    puts("================================================================================")
    puts("Press Enter To Get The Next Page Of 25")
    puts("================================================================================")
    STDOUT.flush
    gets()
  end
end

def display_all(all)
  i = 0
  continue = 0
  for i in 0...all["tickets"].length
      puts("The ID of the #{i}th item is: #{all["tickets"][i]["id"]}")
      puts("The Subject of the #{i}th item is: #{all["tickets"][i]["subject"]}")
    pager(i)
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
    search_string(all, "subject")
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
  found = 0
  found_tickets = Array.new()
  for i in 0...all["tickets"].length
    found_ticket = all["tickets"][i] if all["tickets"][i][specific].include? search
    found_tickets << found_ticket
  end
  found_tickets.each do |i|
    puts("#{search} was found in the #{specific} of the following ticket:")
    puts("ID is: #{i["id"].to_s}")
    puts("Subject is: #{i["subject"]}")
    puts("Priority is: #{i["priority"]}")
    puts("================================================================================")
    found += 1
    pager(found)
  end
end


def main_menu()
  tickets = read_tickets()
  parsed = JSON.parse(tickets.body)
  begin
    puts("Please make a choice between 1 and 3")
    puts("Enter 1 to view all tickets.")
    puts("Enter 2 to search tickets")
    STDOUT.flush
    choice = gets.chomp().to_i
  end while (!(1..2).member?(choice))
  case choice
  when 1
    display_all(parsed)
  when 2
    search_ticket(parsed)
  else
    puts("How did you get here?")
  end
end

def main()
  main_menu()
end

main()
