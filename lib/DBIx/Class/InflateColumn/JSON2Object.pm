package DBIx::Class::InflateColumn::JSON2Object;

use strict;
use warnings;
use JSON::MaybeXS qw(encode_json decode_json);
use Encode qw(encode_utf8 decode_utf8);
use MooseX::Role::Parameterized;

parameter columns => ( is => 'ro', isa => 'ArrayRef', required => 1 );

role {
    my $p        = shift;
    my %args     = @_;
    my $consumer = $args{consumer}->name;

    foreach my $col (@{$p->columns}) {
        my ($column, $class);
        if (ref($col) eq 'ARRAY') {
            ($column, $class) = @$col;
        }
        else {
            $column = $col;
        }

        if ($class) {
        }
        else {
            $consumer->inflate_column(
                $column,
                {   inflate => sub {
                        my $raw = shift;
                        return {}
                            if !defined $raw
                            || $raw =~ m/^\s*$/;
                        return decode_json( encode_utf8($raw) );
                    },
                    deflate => sub {
                        my $data = shift;

                        if ( ref($data) =~ m/^(HASH|ARRAY)$/ ) {
                            return decode_utf8( encode_json($data) );
                        }

                        return $data;
                    },
                }
            );
        }
    }
};

1;
