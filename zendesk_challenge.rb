require 'test/unit'
require 'net/http'
require 'json'
require 'openssl'
require 'base64'
# RIJjudcDGcIB2uxvcyywsG2AISGVZLrZOJRWjScc API TOKEN NOT TO LOSE
# API Token was sadly not useful when using net/http library

URL = 'https://pdsworkshop.zendesk.com/api/v2/tickets.json'

def class_check(var, variable_name, class_type)
  if(!variable_name.is_a?(class_type))
    raise("Variable #{var} expected #{class_type} class type.")
  end
end

def decryption(encoded)
  private_key_file = 'private.pem';

  private_key = OpenSSL::PKey::RSA.new(File.read(private_key_file))
  string = private_key.private_decrypt(Base64.decode64(encoded)).chomp
  return string
end

def enter_credentials()
  begin
    puts("Have you placed supplied 'private.pem' in the same folder as zendesk_challenge.rb or do you want to enter the credentials yourself?")
    puts("* 1. I have placed 'private.pem' inside the same folder as zendesk_challenge.rb.")
    puts("* 2. I would like to enter the credentials myself.")
    STDOUT.flush
    choice = gets.chomp.to_i
  end while(!(1..2).member?(choice))
  if(choice == 1)
    file_data = File.read("credentials.txt").split
    email = file_data[0]
    password = decryption(file_data[1])
    credentials = Array.new
    credentials << email
    credentials << password
    return credentials
  else
    puts("Please enter the user email (pdgeorge.geekpride@gmail.com)")
    STDOUT.flush
    email = gets.chomp
    puts("Please enter the user password (supplied in email)")
    STDOUT.flush
    password = gets.chomp
    credentials = Array.new
    credentials << email
    credentials << password
    return credentials
  end
end

def read_tickets(url, credentials)
  uri = URI(url)

  request = Net::HTTP::Get.new(uri)
  request.basic_auth credentials[0], credentials[1]

  response = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => uri.scheme == "https", :verify_mode => OpenSSL::SSL::VERIFY_NONE) {|http|
    http.request(request)
  }
  return response
end

def pager(x)
  class_check("x in pager", x, Integer)

  if(x % 25 == 0 && x != 0)
    puts("================================================================================")
    puts("Press Enter To Get The Next Page Of 25")
    puts("================================================================================")
    STDOUT.flush
    gets
  end
end

def display_all(all)
  class_check("all in display_all", all, Hash)

  i = 0
  continue = 0
  for i in 0...all["tickets"].length
    puts("The ID of the #{i}th item is: #{all["tickets"][i]["id"]}")
    puts("The Subject of the #{i}th item is: #{all["tickets"][i]["subject"]}")
    pager(i)
  end
end

def search_ticket(all)
  class_check("all in search_ticket", all, Hash)

  begin
    puts("Please make a choice between 1 and 5")
    puts("* Enter 1 to search subjects.")
    puts("* Enter 2 to search descriptions.")
    puts("* Enter 3 to search requester id.")
    puts("* Enter 4 to search assignee id.")
    STDOUT.flush
    choice = gets.chomp.to_i
  end while (!(1..4).member?(choice))
  case choice
  when 1
    search_string(all, "subject")
  when 2
    search_string(all, "description")
  when 3
    puts("An example requester id to use: #{all["tickets"][0]["requester_id"]}")
    search_integer(all, "requester_id")
  when 4
    puts("An example assignee id to use: #{all["tickets"][0]["assignee_id"]}")
    search_integer(all, "assignee_id")
  end
end

def print_results(results, search, specific)
  class_check("results in print_results", results, Array)
  class_check("search in print_results", search, String)
  class_check("specific in search_string", specific, String)

  found = 0
  results.each do |i|
    puts("#{search} was found in the #{specific} of the following ticket:")
    puts("ID is: #{i["id"].to_s}")
    puts("Subject is: #{i["subject"]}")
    puts("Priority is: #{i["priority"]}")
    puts("================================================================================")
    found += 1
    pager(found)
  end
end

def print_detailed(ticket)
  class_check("ticket in print_detailed", ticket, Hash)

  puts("================================================================================")
  puts("ID is: #{ticket["id"].to_s}")
  puts("Requester id is: #{ticket["requester_id"].to_s}")
  puts("Assignee id is: #{ticket["assignee_id"].to_s}")
  puts("Subject is: #{ticket["subject"]}")
  puts("Description is: #{ticket["description"]}")
  puts("The tags are: #{ticket["tags"]}")
  puts("The priority is: #{ticket["priority"]}")
  puts("================================================================================")
end

def search_integer(all, specific)
  class_check("all in search_string", all, Hash)
  class_check("specific in search_integer", specific, String)

  puts("Tell me what you want to find please:")
  STDOUT.flush
  search = gets.chomp
  found_tickets = Array.new
  for i in 0...all["tickets"].length
    found_tickets << all["tickets"][i] if all["tickets"][i][specific] == search.to_i
  end
  puts("Unable to find #{specific}.")if found_tickets.length == 0
  print_results(found_tickets, search, specific)
end

def search_string(all, specific)
  class_check("all in search_string", all, Hash)
  class_check("specific in search_string", specific, String)

  puts("Tell me what you want to find please:")
  STDOUT.flush
  search = gets.chomp
  found = 0
  found_tickets = Array.new
  for i in 0...all["tickets"].length
    found_tickets << all["tickets"][i] if all["tickets"][i][specific].include? search
  end
  puts("Unable to find #{specific}.")if found_tickets.length == 0
  print_results(found_tickets, search, specific)
end

def search_id(all)
  class_check("all in search_id", all, Hash)
  puts("Which ID would you like to find?")
  STDOUT.flush
  search = gets.chomp
  found = false
  for i in 0...all["tickets"].length
    if all["tickets"][i]["id"] == search.to_i
      print_detailed(all["tickets"][i])
      found = true
    end
  end
  puts("Unable to find #{search}.") if found == false
end

def main_menu(parsed_tickets)
  class_check("parsed_tickets in main_menu", parsed_tickets, Hash)
  begin
    puts("\nWelcome to the ticket viewer!")
    begin
      puts("Please make a choice between 1 and 4")
      puts("* Enter 1 to view all tickets")
      puts("* Enter 2 to search tickets")
      puts("* Enter 3 to find a single ticket by ID")
      puts("* Enter 4 to quit")
      STDOUT.flush
      choice = gets.chomp.to_i
    end while (!(1..4).member?(choice))
    case choice
    when 1
      display_all(parsed_tickets)
    when 2
      search_ticket(parsed_tickets)
    when 3
      search_id(parsed_tickets)
    when 4
      puts("Thank you and have a great day.")
      break
    else
      puts("How did you get here?")
    end
  end until false
end

def import_tickets
  credentials = enter_credentials
  tickets = read_tickets(URL, credentials)
  parsed = JSON.parse(tickets.body)
  pages = 2
  if(parsed["tickets"].length == 100)
    to_concatonate = read_tickets(URL+"?page=" + pages.to_s, credentials)
    to_concatonate_parsed = JSON.parse(to_concatonate.body)
    to_concatonate_parsed["tickets"].each do |i|
      parsed["tickets"].append(i)
    end
  end
  while(to_concatonate_parsed["tickets"].length == 100) # Checks if there is 3+ pages. Theoretical at the moment since unable to test.
    pages += 1
    to_concatonate = read_tickets(URL+"?page=" + pages.to_s, credentials)
    to_concatonate_parsed = JSON.parse(to_concatonate.body)
    to_concatonate_parsed["tickets"].each do |i|
      parsed["tickets"].append(i)
    end
  end
  return parsed
end

def error_check
  begin
    parsed = import_tickets
  rescue
    puts("Unable to connect to Zendesk.com.\nPlease ensure the URL is entered correctly, internet access is available and there is no maintanance being performed on Zendesk online functionality before trying again.")
    puts("When you are ready to exit the program, please press enter.")
    STDOUT.flush
    gets
    return
  end

  if parsed.key?("error")
    puts("An error has occured.")
    puts("Error received: #{parsed["error"]}")
    puts("HTTP code received: #{tickets.code}")
    if (parsed["error"].include? "authenticate")
      puts("* Please ensure you have entered the email and password correctly.")
      puts("* If you are certain you entered the correct credentials, please ensure you have enabled password authentication and you did not make 2FA a requirement")
    end
    puts("When you are ready to exit the program, please press enter.")
    STDOUT.flush
    gets
    return
  end

  main_menu(parsed)
end

def main
  error_check
end

main
