package RebirthAPI::Utils;

use strict;
use warnings;
use Exporter 'import';

our @EXPORT_OK = qw(normalize_bson);

sub normalize_bson {
    my ($doc) = @_;
    # If it's undefined or a plain scalar, just return as-is
    return $doc unless defined $doc;

    # If the entire value is a BSON::OID, stringify it
    if (ref($doc) && eval { $doc->isa('BSON::OID') }) {
        return $doc->to_string;
    }

    # If it's a HASH ref, possibly stringify the _id field
    if (ref($doc) eq 'HASH') {
        my $oid = $doc->{_id};
        if (defined $oid && ref($oid) && eval { $oid->can('to_string') }) {
            $doc->{_id} = $oid->to_string;
        }
        return $doc;
    }

    # For ARRAY refs or other structures, return as-is for now
    return $doc;
}

1;
