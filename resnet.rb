require 'net/https'
require 'nokogiri'

# Change these variables!
$username = 'name.#'
$password = nil # Interactive authentication
#$password = 'password' # Use this password instead of asking
$daemon = true

def logged_on?
  res = Net::HTTP.get_response(URI('http://www.google.com/404'))
  res.code != "200"
end

def get_password
  if $password.nil?
    print "Enter your ResNet password: "
    gets.strip
  else
    $password
  end
end
 
def get_login_page_uri
  res = Net::HTTP.get_response(URI('http://www.google.com/404'))
  html = Nokogiri::HTML(res.body) do |config|
    config.nonet # Disable using network during parsing, we aren't connected
  end
  
  # Grab the page we need to go to
  url = html.css("meta").first.attr :content
  url = url[url.index(";URL=")+5..url.index("?")-1]
  uri = URI(URI.escape(url))
end

def get_login_hash (uri)
  https = Net::HTTP.new(uri.host, uri.port)
  https.use_ssl = true
  https.verify_mode = OpenSSL::SSL::VERIFY_PEER

  req = Net::HTTP::Get.new(uri.request_uri)
  res = https.request(req)

  if (res.code == "200")
    # Parse the page for input
    html = Nokogiri::HTML(res.body) do |config|
      config.nonet # Disable using network during parsing, we aren't connected
    end

    hash = {}
    html.css("form input").each do |input|
      if !input['name'].nil? # Keeps the submit button out
        hash[input.attr(:name)] = input.attr(:value)
      end
    end

    # Some manual overrides. Be proud of our OS!
    hash["pm"] = "Linux x86_64"
    hash["username"] = $username
    hash["password"] = get_password

    return hash
  else
    something_changed("Login page did not return 200 OK")
    return false
  end
end

def try_login (uri, post_data)
  https = Net::HTTP.new(uri.host, uri.port)
  https.use_ssl = true
  https.verify_mode = OpenSSL::SSL::VERIFY_PEER

  req = Net::HTTP::Post.new(uri.path)
  req.set_form_data(post_data)

  res = Net::HTTP.start(uri.hostname, uri.port) do |http|
    https.request(req)
  end

  if res.code == "200"
    # Let's see if it worked
    if res.body.include? "You have been successfully logged on the network."
      puts "Logged on."
      return true
    elsif res.body.include? "Invalid"
      puts "Your username and password were wrong. Fix them and try again."
      return false
    else
      something_changed("After POST, the page didn't have either the success of failure strings.");
      puts res.body
      return false
    end
  else
    something_changed('Response after POST was not 200')
    return false
  end
end

def something_changed(message)
  puts 'Something this script expected didn\'t happen.'
  puts 'Contact the script maintainer.' 
  puts 'No login will be attempted for security.'
  puts 'Specifically: ' + message
end

begin
  if !logged_on?
    uri = get_login_page_uri
    post_data = get_login_hash(uri)
    if (post_data)
      # TODO: Grab this from the form's action attribute
      uri.path = "/auth/perfigo_cm_validate.jsp"
      result = try_login(uri, post_data)
      $daemon = false if !result
    else
      $daemon = false
    end
  else
    puts "Already logged in."
  end

  puts "Sleeping." if $daemon
  sleep(30)
end while $daemon

puts 'Done.'
