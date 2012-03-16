#
# Build the CPAN module.
#

use strict;
use Template;
use Carp;
use File::Basename;
use File::Copy;
use File::Find;
use Data::Dumper;
use Cwd;

@ARGV == 1 or die "Usage: $0 version\n";

my $version = shift;

my $module = "Bio-KBase-IDServer";
my $modulec = $module;
$modulec =~ s/-/::/g;

my $tmpdir = "cpantmp";
-d $tmpdir or mkdir($tmpdir) or die "cannot mkdir $tmpdir: $!";

my $mod_dir = "$tmpdir/$module";
-d $mod_dir or mkdir $mod_dir or die "cannot mkdir $mod_dir: $!";

my $lib_dir = "lib/Bio";

my @script_dirs = (qw(scripts));

#
# Copy scripts, ensuring we have #!perl at the top.
#

my @exe_files;
my @manifest;
for my $script_dir (@script_dirs)
{
    my $dst = "$mod_dir/$script_dir";
    -d $dst or mkdir $dst or die "Cannot mkdir $dst: $!";

    for my $path (<$script_dir/*.pl>)
    {
	my $script = basename($path, ".pl");
	push(@exe_files, "$script_dir/$script");
	open(IN, "<", $path) or die "Cannot open $path: $!";
	open(OUT, ">", "$dst/$script") or die "Cannot open $dst/$script: $!";
	print OUT "#!perl\n";
	while (<IN>)
	{
	    print OUT $_;
	}
	close(IN);
	close(OUT);
	push(@manifest, "$script_dir/$script");
    }
}
#
# Use rsync to copy the lib.
#
-d "$mod_dir/lib" or mkdir "$mod_dir/lib";
run("rsync",
    "--exclude", ".#*",
    "--exclude", "CVS",
    "--exclude", "*~",
    "--exclude", "*.pm.bak*",
    "-ar", $lib_dir, "$mod_dir/lib");

#
# Enumerate the files to add to the manifest.
#
find(sub {
    if (-f $_)
    {
	my $t = $File::Find::name;
	$t =~ s,^$mod_dir/,,;
	push(@manifest, $t)
	}
}, $mod_dir);

@manifest = sort @manifest;

my %vars = (module => $modulec,
	    clean_prefix => $module,
	    version => $version,
	    abstract => "The KBase ID server API.",
	    exe_files => \@exe_files,
	    );

my $templ = Template->new();
open(MPL, ">", "$mod_dir/Makefile.PL") or die "Cannot write $mod_dir/Makefile.PL: $!";
$templ->process("cpan/Makefile.PL.tt", \%vars, \*MPL);
close(MPL);

open(M, ">", "$mod_dir/MANIFEST") or die "Cannot write $mod_dir/MANIFEST: $!";
print M "Makefile.PL\n";
print M "$_\n" foreach @manifest;
close(M);

sub run
{
    my(@cmd) = @_;
    my $rc = system(@cmd);
    $rc == 0 or croak "Cmd failed with rc=$rc: @cmd";
}
