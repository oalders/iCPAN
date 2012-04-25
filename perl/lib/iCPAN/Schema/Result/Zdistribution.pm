use utf8;
package iCPAN::Schema::Result::Zdistribution;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

iCPAN::Schema::Result::Zdistribution

=cut

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

=head1 TABLE: C<ZDISTRIBUTION>

=cut

__PACKAGE__->table("ZDISTRIBUTION");

=head1 ACCESSORS

=head2 z_pk

  data_type: 'integer'
  is_auto_increment: 1
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

=head2 zabstract

  data_type: 'varchar'
  is_nullable: 1

=head2 zname

  data_type: 'varchar'
  is_nullable: 1

=head2 zrelease_name

  data_type: 'varchar'
  is_nullable: 1

=head2 zversion

  data_type: 'varchar'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "z_pk",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "z_ent",
  { data_type => "integer", is_nullable => 1 },
  "z_opt",
  { data_type => "integer", is_nullable => 1 },
  "zauthor",
  { data_type => "integer", is_nullable => 1 },
  "zrelease_date",
  { data_type => "timestamp", is_nullable => 1 },
  "zabstract",
  { data_type => "varchar", is_nullable => 1 },
  "zname",
  { data_type => "varchar", is_nullable => 1 },
  "zrelease_name",
  { data_type => "varchar", is_nullable => 1 },
  "zversion",
  { data_type => "varchar", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</z_pk>

=back

=cut

__PACKAGE__->set_primary_key("z_pk");


# Created by DBIx::Class::Schema::Loader v0.07022 @ 2012-04-24 21:33:22
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Z1u3+zj8Ad/a2AggD4Dl1A


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


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
