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
    unless ($result->{success}) {
        if ($result->{code} && $result->{code} eq 'EMAIL_EXISTS') {
            status 409;  # Conflict
        } else {
            status 500;  # Internal server error
        }
        return error($result->{message});
    }

    # Success: extract $user
    my $user = $result->{data};
    my $id = ref($user->{_id}) ? $user->{_id}->to_string : $user->{_id};

    response_header 'Location' => "/api/users/$id" if $id;
    status 201;
    return ok({ user => normalize_bson($user), id => $id });
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
            success => normalize_bson($loggedUser)->{success},
            message => normalize_bson($loggedUser)->{message} 
        });
    } else {
        status 401;
        return error($loggedUser);
        # return error({error => normalize_bson($loggedUser)->{error}});
        # return error({
        #     success => normalize_bson($$loggedUser)->{success},
        #     error => normalize_bson($$loggedUser)->{error}
        # }); # return the error from the Model
    }
}