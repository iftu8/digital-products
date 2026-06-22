require 'webrick'
require 'json'
require 'digest'

# Dynamic User Database Storage (Saves locally inside users.json)
DB_FILE = 'users.json'
PORT = 8080

def read_users
  if File.exist?(DB_FILE)
    begin
      JSON.parse(File.read(DB_FILE))
    rescue
      {}
    end
  else
    {}
  end
end

def write_users(users)
  File.write(DB_FILE, JSON.pretty_generate(users))
end

# Configure custom WEBrick options
server = WEBrick::HTTPServer.new(
  Port: PORT,
  AccessLog: [],
  Logger: WEBrick::Log.new(nil, WEBrick::BasicLog::WARN) # Silent except warnings
)

class AuthServlet < WEBrick::HTTPServlet::AbstractServlet
  # CORS Support Handler
  def do_OPTIONS(req, res)
    set_cors_headers(res)
    res.status = 200
  end

  def do_POST(req, res)
    set_cors_headers(res)
    res['Content-Type'] = 'application/json'

    begin
      # Parse body payload
      data = JSON.parse(req.body || '{}')
      email = data['email']
      password = data['password']

      if email.nil? || email.empty? || password.nil? || password.empty?
        res.status = 400
        res.body = { error: 'Both fields "email" and "password" are required.' }.to_json
        return
      end

      hashed_password = Digest::SHA256.hexdigest(password)
      users = read_users

      # Handle Account Registration
      if req.path == '/api/signup'
        if users[email]
          res.status = 400
          res.body = { error: 'Account already exists. Try signing in!' }.to_json
        else
          users[email] = {
            password: hashed_password,
            created_at: Time.now.to_s
          }
          write_users(users)
          res.status = 201
          res.body = {
            message: 'Registration successful!',
            token: "auth_tok_#{Digest::SHA1.hexdigest(email)}"
          }.to_json
        end

      # Handle Login Verification
      elsif req.path == '/api/login'
        user_entry = users[email]
        if user_entry && user_entry['password'] == hashed_password
          res.status = 200
          res.body = {
            message: 'Successfully authenticated!',
            token: "auth_tok_#{Digest::SHA1.hexdigest(email)}"
          }.to_json
        else
          res.status = 401
          res.body = { error: 'Invalid user credentials.' }.to_json
        end
      else
        res.status = 404
        res.body = { error: 'Not Found' }.to_json
      end

    rescue => e
      res.status = 500
      res.body = { error: "Internal Server Exception: #{e.message}" }.to_json
    end
  end

  private

  def set_cors_headers(res)
    res['Access-Control-Allow-Origin'] = '*'
    res['Access-Control-Allow-Methods'] = 'POST, GET, OPTIONS'
    res['Access-Control-Allow-Headers'] = 'Content-Type, Authorization'
  end
end

# Mount microservice paths to the routing servlet
server.mount '/api/signup', AuthServlet
server.mount '/api/login', AuthServlet

trap('INT') { server.shutdown }

puts "============================================="
puts "   AuraFlow Ruby Authentication Backend v1.0"
puts "============================================="
puts "[*] Microservice is listening on port: #{PORT}"
puts "[*] Access endpoints locally via: http://localhost:#{PORT}"
puts "[i] Exit with Ctrl+C"

server.start