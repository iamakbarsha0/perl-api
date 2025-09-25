package RebirthAPI::Utils;

use strict;
use warnings;
use Exporter 'import';
use JSON qw(decode_json);

our @EXPORT_OK = qw(
    normalize_bson
    normalize_list
    json_body_from_raw
    ok
    error
);

# Convert BSON::OID to string inside a doc
sub normalize_bson {
    my ($doc) = @_;
    return $doc unless defined $doc;

    if (ref($doc) && eval { $doc->isa('BSON::OID') }) {
        return $doc->to_string;
    }

    if (ref($doc) eq 'HASH') {
        my $oid = $doc->{_id};
        if (defined $oid && ref($oid) && eval { $oid->can('to_string') }) {
            $doc->{_id} = $oid->to_string;
        }
        return $doc;
    }

    return $doc;
}

# Normalize an array of docs
sub normalize_list {
    my ($list) = @_;
    return [] unless defined $list && ref($list) eq 'ARRAY';
    my @clean = map { normalize_bson($_) } @$list;
    return \@clean;
}

# Pure JSON decode from raw string
sub json_body_from_raw {
    my ($raw) = @_;
    my $data;
    eval { $data = decode_json($raw // '{}') };
    $data = {} if $@ || !defined $data || ref($data) ne 'HASH';
    return $data;
}

# Success response helper
sub ok {
    my ($payload) = @_;
    $payload ||= {};
    return { success => 1, %{$payload} };
}

# Error response helper
sub error {
    my ($message) = @_;
    $message ||= 'Internal Server Error';
    return { success => 0, error => $message };
}

1;
