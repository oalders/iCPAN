package iCPAN::Schema::Result::Zauthor;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

iCPAN::Schema::Result::Zauthor

=cut

__PACKAGE__->table("ZAUTHOR");

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

=head2 zpauseid

  data_type: 'varchar'
  is_nullable: 1

=head2 zname

  data_type: 'varchar'
  is_nullable: 1

=head2 zemail

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
  "zpauseid",
  { data_type => "varchar", is_nullable => 1 },
  "zname",
  { data_type => "varchar", is_nullable => 1 },
  "zemail",
  { data_type => "varchar", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("z_pk");


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2011-06-02 00:55:09
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:YxApJn+fQPoqQtBwa6U/JA


# You can replace this text with custom code or comments, and it will be preserved on regeneration

__PACKAGE__->has_many(
    Distributions => 'iCPAN::Schema::Result::Zdistribution',
    { 'foreign.zauthor' => 'self.z_pk' }
);

1;
