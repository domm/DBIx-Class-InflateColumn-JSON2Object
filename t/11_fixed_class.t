#!/usr/bin/perl
use Test::More;
use lib 't';
use utf8;
use Encode;
binmode( STDERR, ":utf8" );
binmode( STDOUT, ":utf8" );
use testlib::TestDB qw($dbh $schema);

my $id;
use JSON::MaybeXS;

subtest 'insert object' => sub {

    my $raw_json = '{"flag2":true}';
    my $o = testlib::Object::Fixed->new(decode_json($raw_json));
    use Data::Dumper; $Data::Dumper::Maxdepth=3;$Data::Dumper::Sortkeys=1;warn Data::Dumper::Dumper $o;

    my $obj = testlib::Object::Fixed->new({
        text=>'Manner Schnitten',
        amount=>10,
        more=>{
            original=>'Neapolitaner'
        },
        flag=>1
    });

    my $row = $schema->resultset('Test')->create({fixed_class=>$obj});
    $id = $row->id;

    my ($via_dbi) = $dbh->selectrow_array("select fixed_class from test where id = ?",undef, $id);
    like($via_dbi,qr/"text":"Manner Schnitten"/,'string');
    like($via_dbi,qr/"amount":10/,'int');
    like($via_dbi,qr/"flag":true/,'bool');
};

subtest 'fetch JSON as object' => sub {
    my $row = $schema->resultset('Test')->find($id);
    my $obj = $row->fixed_class;
    is(ref($obj),'testlib::Object::Fixed','class');
    is($obj->text,'Manner Schnitten','text');
    is($obj->more->{original},'Neapolitaner','hashref');
    is($obj->flag,1,'flag');
};

subtest 'fetch and update' => sub {
    my $row = $schema->resultset('Test')->find($id);

    my $obj = testlib::Object::Fixed->new({
        text=>'Manner Schnitten',
        amount=>2,
        flag=>0
    });

    $row->update({fixed_class=>$obj});

    my $fresh = $schema->resultset('Test')->find($id);
    is($fresh->fixed_class->amount,2,'only 2 left');
    is($fresh->fixed_class->flag,0,'boolean false');

    my $raw = $fresh->get_column('fixed_class');
    like($raw,qr/"text":"Manner Schnitten"/,'raw text');
    like($raw,qr/"amount":2/,'raw int');
    like($raw,qr/"flag":false/,'raw boolean');
};

subtest 'insert object from raw json' => sub {

    my $raw_json = '{"text":"JSON","amount":13,"flag":true}';
    my $obj = testlib::Object::Fixed->new(decode_json($raw_json));

    my $row = $schema->resultset('Test')->create({fixed_class=>$obj});
    $row->discard_changes;
    is($row->fixed_class->text,'JSON','text');
    is($row->fixed_class->amount,13,'amount');
    is($row->fixed_class->flag,1,'boolean true');
};

done_testing();
