package DBIx::Class::InflateColumn::JSON2Object;

# ABSTRACT: convert JSON columns to Perl objects

our $VERSION = '0.001';

use strict;
use warnings;
use JSON::MaybeXS qw(encode_json decode_json );
use Encode qw(encode_utf8 decode_utf8);
use Module::Runtime 'use_module';
use Scalar::Util qw(blessed);

sub class_in_column {
    my ($class,@args) = @_;
    my $caller = caller(0);

    foreach my $def (@args) {

        my $class_column    = $def->{class_column};
        my $data_column     = $def->{data_column};
        my $namespace       = $def->{namespace};
        my $result_source   = $def->{result_source} || $caller;

        use_module($namespace);

        $result_source->inflate_column(
            $data_column,
            {
                inflate => sub {
                    my ($data,$self) = @_;
                    my $package = $namespace->package($self->$class_column);
                    return $package->thaw($data);
                },
                deflate => sub {
                    my ($data,$self) = @_;
                    if (blessed $data) {
                        if ($data->isa($namespace)) {
                            $self->$class_column($data->moniker);
                        } else {
                            die('Supplied args object is not a '.$namespace);
                        }
                    } else {
                        my $package = $namespace->package($self->$class_column);
                        $data = $package->thaw($data);
                    }
                    return $data->freeze;
                },
            }
        );
    }
}

sub fixed_class {
    my ($class,@args) = @_;
    my $caller = caller(0);

    foreach my $def (@args) {

        my $data_column   = $def->{column};
        my $package       = $def->{class};
        my $result_source = $def->{result_source} || $caller;

        use_module($package);

        $result_source->inflate_column(
            $data_column,
            {
                inflate => sub {
                    my ($data,$self) = @_;
                    return $package->thaw($data);
            },
                deflate => sub {
                    my ($data,$self) = @_;
                    if (blessed $data) {
                        if (!$data->isa($package)) {
                            die('Supplied args object is not a '.$package);
                        }
                    } else {
                        $data = $package->thaw($data);
                    }
                    return $data->freeze;
                },
            }
        );
    }
}

sub no_class {
    my ($class,@args) = @_;
    my $caller = caller(0);

    foreach my $def (@args) {

        my $data_column     = $def->{column};
        my $result_source   = $def->{result_source} || $caller;

        $result_source->inflate_column(
            $data_column,
            {
                inflate => sub {
                    my ($data,$self) = @_;
                    return {}
                        if !defined $data
                            || $data =~ m/^\s*$/;
                    return decode_json( encode_utf8($data) );
                },
                deflate => sub {
                    my ($data,$self) = @_;
                    if ( ref($data) =~ m/^(HASH|ARRAY)$/ ) {
                        return decode_utf8( encode_json($data) );
                    }
                    return $data;
                },
            }
        );
    }
}

1;

__END__

=head1 SYNOPSIS

TODO

=head1 DESCRIPTION

Do not use yet, this is Alpha-Code!





