package DBIx::Class::InflateColumn::JSON2Object::Trait::NoSerialize;
use Moose::Role;

# ABSTRACT: NoSerialize trait for attributes

package Moose::Meta::Attribute::Custom::Trait::NoSerialize {
    sub register_implementation { 'DBIx::Class::InflateColumn::JSON2Object::Trait::NoSerialize' }
}

1;
