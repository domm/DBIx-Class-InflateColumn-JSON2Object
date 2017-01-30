#!/usr/bin/perl
use Test::More;
use lib 'lib';

foreach my $mod (qw(DBIx::Class::InflateColumn::JSON2Object DBIx::Class::InflateColumn::Role::Storable DBIx::Class::InflateColumn::Trait::NoSerialize)) {
    require_ok($mod);
}

done_testing();
