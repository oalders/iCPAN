package iCPAN::Schema::Result::Zmodule;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

iCPAN::Schema::Result::Zmodule

=cut

__PACKAGE__->table("ZMODULE");

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

=head2 zdistribution

  data_type: 'integer'
  is_nullable: 1

=head2 zabstract

  data_type: 'varchar'
  is_nullable: 1

=head2 zname

  data_type: 'varchar'
  is_nullable: 1

=head2 zpod

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
  "zdistribution",
  { data_type => "integer", is_nullable => 1 },
  "zabstract",
  { data_type => "varchar", is_nullable => 1 },
  "zname",
  { data_type => "varchar", is_nullable => 1 },
  "zpod",
  { data_type => "varchar", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("z_pk");


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2011-06-02 00:55:09
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:yq/mEdLbcmO4VCW4B+T53g


# You can replace this text with custom code or comments, and it will be preserved on regeneration

__PACKAGE__->add_columns(
  "zpath",
  { data_type => "varchar", is_nullable => 1 },
);
__PACKAGE__->belongs_to(
    Distribution => 'iCPAN::Schema::Result::Zdistribution',
    { 'foreign.z_pk' => 'self.zdistribution' }
);

1;
