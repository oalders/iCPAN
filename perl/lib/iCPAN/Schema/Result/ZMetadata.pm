use utf8;
package iCPAN::Schema::Result::ZMetadata;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

iCPAN::Schema::Result::ZMetadata

=cut

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

=head1 TABLE: C<Z_METADATA>

=cut

__PACKAGE__->table("Z_METADATA");

=head1 ACCESSORS

=head2 z_version

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 z_uuid

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 z_plist

  data_type: 'blob'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "z_version",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "z_uuid",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "z_plist",
  { data_type => "blob", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</z_version>

=back

=cut

__PACKAGE__->set_primary_key("z_version");


# Created by DBIx::Class::Schema::Loader v0.07022 @ 2012-04-24 21:33:22
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:TErXKIc1gli7ZkXGgIPQiw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
