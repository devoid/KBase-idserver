
=head1 NAME

register-genome-dir

=head1 DESCRIPTION

Read the standard form of a genome directory, and write a new genome
directory which has all identifiers registered and rewritten as KB ids.

=cut

use IDServerAPIClient;
use Data::Dumper;
use Time::HiRes 'gettimeofday';
use common::sense;

$| = 1;

@ARGV == 3 or die "Usage: $0 dbname from-dir to-dir\n";

my $dbname = shift;
my $from_dir = shift;
my $to_dir = shift;

if (! -d $from_dir)
{
    die "Source directory $from_dir does not exist\n";
}

if (0 && -d $to_dir)
{
    die "Target directory $to_dir already exists\n";
}

if (! -d $to_dir)
{
    mkdir $to_dir or die "Cannot mkdir $to_dir: $!";
}

my $idserv = IDServerAPIClient->new('http://bio-data-1.mcs.anl.gov:8080/services/idserver');
#my $idserv = IDServerAPIClient->new('http://ash.mcs.anl.gov:5000');

#
# Global state variables
#
my($genome, $kgenome);
my %feature_to_kfeature;

my %feature_type_map = (peg => 'fp',
			rna => 'fr');


my $start = gettimeofday;
print "register $from_dir\n";
process_name(open_handles("name.tab"));
process_features(open_handles("features.tab"));
process_contigs(open_handles("contigs.fa"));
process_functions(open_handles("functions.tab"));
process_proteins(open_handles("proteins.fa"));
process_attributes(open_handles("attributes.tab"));
my $end = gettimeofday;
my $elap = $end - $start;
printf "Done $kgenome %.1f\n", $elap;

sub process_name
{
    my($from, $to) = @_;

    my $l = <$from>;

    chomp $l;
    my $name;
    ($genome, $name) = split(/\t/, $l);

    #
    # Do we already have?
    #
    my $res = $idserv->external_ids_to_kbase_ids($dbname, [$genome]);
    if (!$res->{$genome})
    {
	$res = $idserv->register_ids('kb|g', $dbname, [$genome]);
    }
    
    $kgenome = $res->{$genome};

    print $to join("\t", $kgenome, $name), "\n";
}

=head3 process_features

Scan the feature table looking for the features we need to map (using
C<%feature_type_map>).

=cut
    
sub process_features
{
    my($from, $to) = @_;

    my %features_of_type;
    my @all_data;
    while (<$from>)
    {
	chomp;
	my($id, $type, @data) = split(/\t/);
	if (exists($feature_type_map{$type}))
	{
	    push(@{$features_of_type{$type}}, $id);
	    push(@all_data, [$id, \@data]);
	}
    }

    #
    # Find existing registrations.
    #

    my $existing = $idserv->external_ids_to_kbase_ids($dbname, [map { $_->[0] } @all_data]);

    #
    # By type, find the ones that do not exist, and register.
    #

    %feature_to_kfeature = %$existing;
    
    for my $type (keys %features_of_type)
    {
	my $tids = $features_of_type{$type};

	my @need = grep { !$existing->{$_} } @$tids;

	my $prefix = "$kgenome.$feature_type_map{$type}";
	my $new = $idserv->register_ids($prefix, $dbname, \@need);

	$feature_to_kfeature{$_} = $new->{$_} foreach keys %$new;
    }

    #
    # And write the output file.
    #

    for my $row (@all_data)
    {
	my($id, $rest) = @$row;
	print $to join("\t", $feature_to_kfeature{$id}, @$rest), "\n";
    }
}

sub process_contigs
{
    my($from, $to) = @_;
    while (<$from>)
    {
	if (/^>(\S+)(.*)$/)
	{
	    print $to ">$kgenome:$1$2\n";
	}
	else
	{
	    print $to $_;
	}
    }
}

sub process_functions
{
    my($from, $to) = @_;

    while (<$from>)
    {
	my($id, $fn) = split(/\t/, $_, 2);
	if (exists($feature_to_kfeature{$id}))
	{
	    print $to $feature_to_kfeature{$id}, "\t", $fn;
	}
    }
}

sub process_proteins
{
    my($from, $to) = @_;

    my $ok;
    while (<$from>)
    {
	if (/^>(\S+)(.*)$/)
	{
	    $ok = exists($feature_to_kfeature{$1});
	    if ($ok)
	    {
		print $to ">$feature_to_kfeature{$1}$2\n";
	    }
	}
	elsif ($ok)
	{
	    print $to $_;
	}
    }
}

sub process_attributes
{
    my($from, $to) = @_;
    #
    # Nothing needs to be done for now.
    #
    while (<$from>)
    {
	print $to $_;
    }
}


sub open_handles
{
    my($name) = @_;
    my ($from, $to);

    open($from, "<", "$from_dir/$name") or die "Cannot open $from_dir/$name for reading: $!";
    open($to, ">", "$to_dir/$name") or die "Cannot open $to_dir/$name for writing: $!";

    return($from, $to);
}
