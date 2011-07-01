package iCPAN::Schema::Result::ZMetadata;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

iCPAN::Schema::Result::ZMetadata

=cut

__PACKAGE__->table("Z_METADATA");

=head1 ACCESSORS

=head2 z_version

  data_type: 'integer'
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
  { data_type => "integer", is_nullable => 0 },
  "z_uuid",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "z_plist",
  { data_type => "blob", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("z_version");


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2011-06-02 00:55:09
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:1UzlAop/aPzBOfJAgRE9iw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
