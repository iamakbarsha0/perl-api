package RebirthAPI::Routes::Auth;

use strict;
use warnings;

use Dancer2 appname => "RebirthAPI::App";

use RebirthAPI::Models::Auth;
use RebirthAPI::Utils qw (ok error normalize_bson json_body_from_raw);

# ------------------------
# signup
# ------------------------
post '/api/auth/signup' => sub {
    my $payload = json_body_from_raw(request->body);

    # Declare $result properly
    my $result = RebirthAPI::Models::Auth::create_user($payload);

    # Handle errors
    if (!$result->{success}) {
        status $result->{code} && $result->{code} eq 'EMAIL_EXISTS' ? 409 : 500;
        return error($result->{message});
    }

    # Success: extract $user
    my $user = $result->{data};
    my $id = ref($user->{_id}) ? $user->{_id}->to_string : $user->{_id};

    response_header 'Location' => "/api/users/$id" if $id;
    status 201;
    return ok({ user => normalize_bson($user), id => $id }, "User created successfully");
};

# ------------------------
# login
# ------------------------
post '/api/auth/login' => sub {
    my $data = body_parameters->as_hashref; # get JSON from request

    my $loggedUser = eval { RebirthAPI::Models::Auth::auth_login($data) };
    
    if ($@) {
        status 500;
        return error("Internal error: $@");
    }

    if($loggedUser->{success}) {
        status 200;
         return ok({ 
            user => normalize_bson($loggedUser->{user}) 
        }, "Login success");
    } else {
        status 401;
        return error($loggedUser->{error} || "Invalid credentials");
    }
}