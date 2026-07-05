class ApplicationController < ActionController::API
    # Runs the callback before every action in all controllers that inherit from ApplicationController. As a result every API request requires
    # authentication, except for actions where this callback is explicitly skipped.
    before_action :authenticate_user!
    # Rescues the ActiveRecord::RecordNotFound exception, which is raised when a requested record cannot be found in the database.
    # Instead of returning the default Rails error response, it points to the not_found method, which returns a 404 Not Found response
    rescue_from ActiveRecord::RecordNotFound, with: :not_found

    # private methods
    private
    def authenticate_user!
        # request – the object representing the incoming HTTP request (available in the controller), headers – a hash containing all HTTP headers
        # sent by the client, ['Authorization'] – retrieves the value of the Authorization header
        # &. - the safe navigation operator. If the object is nil, it returns nil instead of raising a NoMethodError
        # .split(' ') - splits a string into an array of substrings using a space (' ') as the delimiter
        # last - returns the last element of the array, in this case the Jwt itself
        token = request.headers["Authorization"]&.split(" ")&.last
        # Checks whether the token variable is present
        if token
        # opens a `begin` block, allowing exceptions that may occur within the block to be handled
        begin
            # JWT.decode - a method provided by the jwt gem that decodes and verifies a JWT.
            # It accepts four arguments : token – the JWT string to decode, secret – the secret key used to verify the token's signature,
            # verify – whether the token should be verified (true enables signature verification), options – a hash of additional options
            # such as the signing algorithm
            # .secret_key_base - is a unique secret key generated for each Rails application. It is used to sign session cookies and
            # authentication tokens. The key is stored in config/credentials.yml.enc. If secret_key_base is nil, JWT.decode
            # raises an exception because it cannot verify the token's signature.
            # If the token contains an exp (expiration) parameter, JWT automatically checks whether the token has expired.
            # If it has expired, it raises a JWT::ExpiredSignature exception.
            # What JWT.decode returns? In returns a table with two elements
            # [
            #    { "user_id" => 1, "exp" => 1719937800 },
            #    { "alg" => "HS256" }
            # ]
            decoded = JWT.decode(token, Rails.application.credentials.secret_key_base, true, algorithm: "HS256")
            # User.find(...) - looks for a user with this parameters (...)
            # decoded[0] - returns the first element of the array, ['user_id'] - refers to a value extracted from the first element of the array
            @current_user = User.find(decoded[0]["user_id"])
        # JWT::DecodeError – an exception raised by JWT.decode when the token is : invalid (modified or forged), in an incorrect format,
        # unable to be decoded, signed with an unknown or unsupported algorithm.
        # When this exception occurs, the code inside the rescue block is executed.
        # It returns a JSON response with the error message 'Invalid token' and an HTTP status code 401 Unauthorized
        rescue JWT::DecodeError
            render json: { error: "Invalid token" }, status: :unauthorized
        end
        # If no exception occurs and the token is falsy or does not exist, the code returns error message 'Missing token' and an HTTP status code 401 Unauthorized
        else
            render json: { error: "Missing token" }, status: :unauthorized
        end
    end
    def not_found
        # status: :not_found - sets the HTTP status code to 404 Not Found
        render json: { error: "Resource not found" }, status: :not_found
    end
end
