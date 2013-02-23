#!/usr/bin/env perl

BEGIN { $ENV{CATALYST_DEBUG} = 0 }
use strict;
use warnings;
use FindBin '$Bin';
use lib "$Bin/../lib";
use Observer::Schema;
use Config::JFDI;

my ( $dsn, $dbuser, $dbpass );

my $jfdi = Config::JFDI->new(name => "Observer");
my $config = $jfdi->get;

eval {
    unless ($dsn) {
        if (ref $config->{'Model::DB'}->{'connect_info'}) {
            $dsn = $config->{'Model::DB'}->{'connect_info'}->{'dsn'};
            $dbuser = $config->{'Model::DB'}->{'connect_info'}->{'user'};
            $dbpass = $config->{'Model::DB'}->{'connect_info'}->{'pass'};
        } else {
            $dsn = $config->{'Model::DB'}->{'connect_info'};
        }
    };
};
if($@){
    die "Your DSN line in observer.conf doesn't look like a valid DSN.".
      "  Add one, or pass it on the command line.";
}
die "No valid Data Source Name (DSN). \n" unless $dsn;
$dsn =~ s/__HOME__/$FindBin::Bin\/\.\./g;

my $schema = Observer::Schema->connect($dsn, $dbuser, $dbpass)
    or die "Failed to connect to database";

# Check if database is already deployed by
# examining if the table Person exists and has a record.
#eval {  $schema->resultset('Observer::Schema::Result::Users')->count };
#if (!$@ ) {
#    die "You have already deployed your database\n";
#}

print "Deploying schema to $dsn\n";
$schema->deploy;

#$schema->create_initial_data($config);
