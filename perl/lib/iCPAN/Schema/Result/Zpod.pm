package iCPAN::Schema::Result::Zpod;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

iCPAN::Schema::Result::Zpod

=cut

__PACKAGE__->table("ZPOD");

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

=head2 zmodule

  data_type: 'integer'
  is_nullable: 1

=head2 zhtml

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
  "zmodule",
  { data_type => "integer", is_nullable => 1 },
  "zhtml",
  { data_type => "varchar", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("z_pk");


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2011-07-03 23:55:39
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:MUO/ml8uiUGNn5/TRoDz6g


# You can replace this text with custom code or comments, and it will be preserved on regeneration

__PACKAGE__->belongs_to(
    Module => 'iCPAN::Schema::Result::Zmodule',
    { 'foreign.z_pk' => 'self.zmodule' }
);


1;
