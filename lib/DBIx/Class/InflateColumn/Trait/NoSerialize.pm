package DBIx::Class::InflateColumn::Trait::NoSerialize;
use Moose::Role;

# ABSTRACT: NoSerialize trait for attributes

package Moose::Meta::Attribute::Custom::Trait::NoSerialize {
    sub register_implementation { 'DBIx::Class::InflateColumn::Trait::NoSerialize' }
}

1;
