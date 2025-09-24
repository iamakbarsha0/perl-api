package RebirthAPI::Utils;

use strict;
use warnings;
use Exporter 'import';

our @EXPORT_OK = qw(normalize_bson);

sub normalize_bson {
    my ($doc) = @_;
    my %copy = %$doc;

    for my $k (keys %copy) {
        if (ref($copy{$k}) eq 'BSON::OID') {
            $copy{$k} = $copy{$k}->to_string;
        }
        elsif (ref($copy{$k}) eq 'BSON::Int64') {
            $copy{$k} = 0 + $copy{$k};
        }
        elsif (ref($copy{$k}) eq 'DateTime') {
            $copy{$k} = $copy{$k}->iso8601;
        }
    }

    return \%copy;
}

1;
