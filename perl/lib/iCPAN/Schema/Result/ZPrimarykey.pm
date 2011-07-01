package iCPAN::Schema::Result::ZPrimarykey;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

iCPAN::Schema::Result::ZPrimarykey

=cut

__PACKAGE__->table("Z_PRIMARYKEY");

=head1 ACCESSORS

=head2 z_ent

  data_type: 'integer'
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
  { data_type => "integer", is_nullable => 0 },
  "z_name",
  { data_type => "varchar", is_nullable => 1 },
  "z_super",
  { data_type => "integer", is_nullable => 1 },
  "z_max",
  { data_type => "integer", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("z_ent");


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2011-06-02 00:55:09
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:sZZ3fNdaXlfaGO+Y1LbuLA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
