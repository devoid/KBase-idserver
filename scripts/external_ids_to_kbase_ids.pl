use strict;
use Data::Dumper;
use Carp;
use Getopt::Long;

#
# This is a SAS Component
#

=head1 external_ids_to_kbase_ids

Given a set of external identifiers, look up the associated KBase identifiers.
If no KBase ID is associated with the external id, no entry will be present in the return.

Example:

    external_ids_to_kbase_ids DB-name < input > output

The standard input should be a tab-separated table (i.e., each line
is a tab-separated set of fields).  Normally, the last field in each
line would contain the identifer. If another column contains the identifier
use

    -c N

where N is the column (from 1) that contains the identifier.

This is a pipe command. The input is taken from the standard input, and the
output is to the standard output.

=head2 Command-Line Options

=over 4

=item DB-name

The name of the external database to look up.

=item -c Column

This is used only if the column containing the identifier is not the last column.

=item -i InputFile    [ use InputFile, rather than stdin ]

=back

=head2 Output Format

The standard output is a tab-delimited file. It consists of the input
file with extra columns added.

Input lines that cannot be extended are written to stderr.

=cut

my $usage = "usage: external_ids_to_kbase_ids [-c column] DB-name < input > output\n";

use Bio::KBase;
use Bio::KBase::Utilities::ScriptThing;

my $column;

my $input_file;

my $kb = Bio::KBase->new();
my $idserver = $kb->id_server();

my $rc = GetOptions('c=i' => \$column,
		    'i=s' => \$input_file);


(@ARGV == 1 && $rc) or die $usage;

my $ext_db = shift;

my $ih;
if ($input_file)
{
    open $ih, "<", $input_file or die "Cannot open input file $input_file: $!";
}
else
{
    $ih = \*STDIN;
}

while (my @tuples = Bio::KBase::Utilities::ScriptThing::GetBatch($ih, undef, $column)) {
    my @h = map { $_->[0] } @tuples;
    my $h = $idserver->external_ids_to_kbase_ids($ext_db, \@h);
    for my $tuple (@tuples) {
        #
        # Process output here and print.
        #
        my ($id, $line) = @$tuple;
        my $v = $h->{$id};

        if (! defined($v))
        {
            print STDERR $line,"\n";
        }
        elsif (ref($v) eq 'ARRAY')
        {
            foreach $_ (@$v)
            {
                print "$line\t$_\n";
            }
        }
        else
        {
            print "$line\t$v\n";
        }
    }
}
