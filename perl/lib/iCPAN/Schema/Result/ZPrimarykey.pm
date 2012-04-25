use utf8;
package iCPAN::Schema::Result::ZPrimarykey;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

iCPAN::Schema::Result::ZPrimarykey

=cut

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

=head1 TABLE: C<Z_PRIMARYKEY>

=cut

__PACKAGE__->table("Z_PRIMARYKEY");

=head1 ACCESSORS

=head2 z_ent

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 z_name

  data_type: 'varchar'
  is_nullable: 1

=head2 z_super

  data_type: 'integer'
  is_nullable: 1

=head2 z_max

  data_type: 'integer'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "z_ent",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "z_name",
  { data_type => "varchar", is_nullable => 1 },
  "z_super",
  { data_type => "integer", is_nullable => 1 },
  "z_max",
  { data_type => "integer", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</z_ent>

=back

=cut

__PACKAGE__->set_primary_key("z_ent");


# Created by DBIx::Class::Schema::Loader v0.07022 @ 2012-04-24 21:33:22
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:SW2RzjgU/NJakrD7jiAIXQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
