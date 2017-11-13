#!/usr/bin/perl
use strict;
use warnings;

use Getopt::Long qw(GetOptions);

sub usage {
  print "Usage: poolhost -u <username> -p <password> -id poolid [-out <filename>]\n";
  exit;
}

sub Has_404 {
  my @lines = @_;
  # Count the # of 400 status codes
  # this isn't exact, because poolhost does a bunch of redirects for
  # whatever reason
  foreach my $line(@lines) {
   return 1 if $line =~ m/HTTP\/1.1 404/;
  }

  return 0;
}

my $username;
my $password;
my $pool_id;
my $export_filename = "picks.xls";
my $help = 0;
my @hostnames = ('www3.poolhost.com',
                 'www5.poolhost.com',
                 'www8.poolhost.com',
                 'www.poolhost.com');
my $good_hostname = 0;

GetOptions('u=s' => \$username,
           'p=s' => \$password,
           'id=s' => \$pool_id,
           'out=s' => \$export_filename,
           'h!' => \$help,
) or usage();

if ($help) {
  usage();
}

usage() unless defined $username;
usage() unless defined $password;
usage() unless defined $pool_id;

foreach my $hostname (@hostnames) {
  # Have to do this call to log in and get the first session cookie
  my @login_lines =
    qx{curl -L -i --data-urlencode "Username=$username" \\
                  --data-urlencode "Password=$password" \\
                  --data-urlencode "Admin=" \\
                  --data-urlencode "Action=Login" \\
                  https://$hostname/index.asp?page=login.asp \\
                  -b poolhost_cookies \\
                  -c poolhost_cookies};

  # Check to see if we got a 404.
  unless (Has_404(@login_lines)) {
    # We hope at this point that one good hostname means they'll
    # all subsequently be good?  But who knows!
    $good_hostname = 1;

    # Then do this to get the next poolid cookie (41149)
    my @ham_lines =
      qx {curl -L -X GET "http://$hostname/index.asp?page=mypools.asp&poolid=$pool_id&pool_dir=" \\
                     -b poolhost_cookies \\
                     -c poolhost_cookies};

    # Then get the xls of the picks for the week
    my @picks_lines =
      qx {curl -X GET "http://$hostname/index.asp?page=allpicks.asp&exp=1" \\
                   -b poolhost_cookies \\
                   -c poolhost_cookies > $export_filename};
  } else {
    next;   # try the next hostname
  }
 }

 unless ($good_hostname) {
   print "Couldn't find a good hostname for poolhost.";
   exit;
 }

# Remove the cookie file
unlink "poolhost_cookies"
