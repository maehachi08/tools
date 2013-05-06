package MoosexGetopt;
use Moose;

with 'MooseX::Getopt';

has 'arg1' => (
    is       => 'rw',
    isa      => 'Str',
    required => 1,
);

__PACKAGE__->meta->make_immutable;

no Moose;
