package iCPAN::Schema::Result::Zdistribution;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

iCPAN::Schema::Result::Zdistribution

=cut

__PACKAGE__->table("ZDISTRIBUTION");

=head1 ACCESSORS

=head2 z_pk

  data_type: 'integer'
  is_nullable: 0

=head2 z_ent

  data_type: 'integer'
  is_nullable: 1

=head2 z_opt

  data_type: 'integer'
  is_nullable: 1

=head2 zauthor

  data_type: 'integer'
  is_nullable: 1

=head2 zrelease_date

  data_type: 'timestamp'
  is_nullable: 1

=head2 zname

  data_type: 'varchar'
  is_nullable: 1

=head2 zversion

  data_type: 'varchar'
  is_nullable: 1

=head2 zabstract

  data_type: 'varchar'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "z_pk",
  { data_type => "integer", is_nullable => 0 },
  "z_ent",
  { data_type => "integer", is_nullable => 1 },
  "z_opt",
  { data_type => "integer", is_nullable => 1 },
  "zauthor",
  { data_type => "integer", is_nullable => 1 },
  "zrelease_date",
  { data_type => "timestamp", is_nullable => 1 },
  "zname",
  { data_type => "varchar", is_nullable => 1 },
  "zversion",
  { data_type => "varchar", is_nullable => 1 },
  "zabstract",
  { data_type => "varchar", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("z_pk");


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2011-06-02 00:55:09
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:BTwyAK6PuyxInQ7ru3kIYg


# You can replace this text with custom code or comments, and it will be preserved on regeneration

__PACKAGE__->add_columns(
  "zrelease_name",
  { data_type => "varchar", is_nullable => 1 },
);

__PACKAGE__->belongs_to(
    Author => 'iCPAN::Schema::Result::Zauthor',
    { 'foreign.z_pk' => 'self.zauthor' }
);

__PACKAGE__->has_many(
    Modules => 'iCPAN::Schema::Result::Zmodule',
    { 'foreign.zdistribution' => 'self.z_pk' }
);

1;
