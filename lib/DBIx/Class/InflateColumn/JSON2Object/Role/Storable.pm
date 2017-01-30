package DBIx::Class::InflateColumn::JSON2Object::Role::Storable;

# ABSTRACT: simplified MooseX::Storage clone with enhanced JSON boolean handling

use Moose::Role;

use DBIx::Class::InflateColumn::JSON2Object::Trait::NoSerialize;
use JSON::MaybeXS;
use String::CamelCase qw(camelize decamelize);

use Moose::Util::TypeConstraints;

subtype 'InflateColumnJSONBool',
  as class_type('JSON::PP::Boolean');

coerce 'InflateColumnJSONBool',
    from 'JSON::PP::Boolean',
    via { $_ ? 1 : 0 };
coerce 'InflateColumnJSONBool',
    from 'Str',
    via { $_ ? JSON->true : JSON->false };
coerce 'InflateColumnJSONBool',
    from 'Int',
    via { $_ ? JSON->true : JSON->false };

sub freeze {
    my ($self) = @_;

    my $payload = $self->pack;
    my $json = encode_json($payload);

    # stolen from MooseX::Storage
    utf8::decode($json) if !utf8::is_utf8($json) and utf8::valid($json);
    return $json;
}

sub thaw {
    my ($class,$payload) = @_;

    # stolen from MooseX::Storage
    utf8::encode($payload) if utf8::is_utf8($payload);

    $payload = decode_json($payload) unless ref($payload);
    return $class->new($payload);
}

sub pack {
    my ($self) = @_;

    my $payload = {};
    foreach my $attribute ($self->meta->get_all_attributes) {
        next
            if $attribute->does('DBIx::Class::InflateColumn::Trait::NoSerialize');
        my $val = $attribute->get_value($self);
        $payload->{$attribute->name} = $val if defined $val;
    }
    return $payload;
}

sub moniker {
    my ($self) = @_;
    my $class = ref($self) || $self;
    $class =~ /::([^:]+)$/;
    return decamelize($1);
}

sub package {
    my ($class,$moniker) = @_;
    return $class.'::'.camelize($moniker)
}

1;
