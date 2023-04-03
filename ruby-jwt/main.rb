require 'sinatra'
require 'jwt'
require 'openssl'
require 'json'

PRIVATE_KEY = OpenSSL::PKey::RSA.generate(2048)
PUBLIC_KEY = PRIVATE_KEY.public_key



# Helper method to generate JWT tokens
def generate_token(payload)
  # JWT.encode(payload, 'your_secret_key', 'HS256')
  headers = {
    exp: Time.now.to_i + 20 #expire in 20 seconds
  }
  JWT.encode(payload, PRIVATE_KEY, 'RS256', headers)
end


# Helper method to validate JWT tokens
def validate_token(token)
  begin
    # Decode the token using the secret key
    decoded_token, header = JWT.decode(token, PRIVATE_KEY, true, { algorithm: 'RS256' })

    # Return the decoded payload
    # decoded_token.first
    exp = header["exp"]

    if exp.nil?
      # session["message"] = "No exp set on JWT token."
      p 'no exp set'
      return false
    end

    exp = Time.at(exp.to_i)

    # make sure the token hasn't expired
    if Time.now > exp
      session["message"] = "JWT token expired."
      p 'token expired'
      return false
    end
    decoded_token
  rescue JWT::ExpiredSignature, JWT::VerificationError, JWT::DecodeError
    # Return nil if the token is invalid
    p 'invalid token'
    nil
  end
end


# before do
# end

options "*" do
  # response.headers["Allow"] = "GET, PUT, POST, DELETE, OPTIONS"
  response.headers["Access-Control-Allow-Methods"] = "GET, PUT, POST, DELETE, OPTIONS"
  response.headers["Access-Control-Allow-Headers"] = "Authorization, Content-Type, Accept, X-User-Email, X-Auth-Token"
  # response.headers["Access-Control-Allow-Origin"] = "*"
  200
end


before do
  response.headers['Access-Control-Allow-Origin'] = 'http://localhost:3000'
  content_type :json
end

# Route to handle user authentication and generate JWT token
post '/login' do
  p 'receiving loging request'
  params = JSON.parse(request.body.read, symbolize_names: true)
  # Replace these with your actual authentication logic
  username = params[:username]
  password = params[:password]

  # Verify the user's credentials
  if username == 'admin' && password == 'password'
    # Generate a token with the user's ID as the payload
    token = generate_token({ user_id: 1 })

    # Return the token as a JSON response
    { token: token }.to_json
  else
    # Return an error response if the authentication fails
    halt 401, { error: 'Invalid credentials' }.to_json
  end
end


# post '/login' do
#   # Authenticate user
#   # ...
#   # Generate JWT token
#   payload = { username: 'johndoe' }
#   token = JWT.encode payload, PRIVATE_KEY, 'RS256'
#   { token: token }.to_json
# end


# Protected route that requires a valid JWT token
get '/protected' do
  p 'receiving access to protected area'
  # Get the token from the Authorization header
  token = request.env['HTTP_AUTHORIZATION']&.split&.last

  # Validate the token
  payload = validate_token(token)

  # If the token is valid, return the user ID from the payload
  if payload && payload['user_id']
    {"secure": "data"}.to_json
  else
    # Return an error response if the token is invalid
    halt 401, { error: 'Invalid token' }.to_json
  end
end