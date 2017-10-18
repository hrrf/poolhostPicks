#!/usr/bin/perl
use strict;
use warnings;

use Getopt::Long qw(GetOptions);

sub usage {
  print "Usage: poolhost -u <username> -p <password> -id poolid [-out <filename>]\n";
  exit;
}

my $username;
my $password;
my $pool_id;
my $export_filename = "picks.xls";
my $help = 0;

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

# Have to do this call to log in and get the first session cookie
my @login_lines =
  qx{curl -L --data-urlencode "Username=$username" \\
                --data-urlencode "Password=$password" \\
                --data-urlencode "Admin=" \\
                --data-urlencode "Action=Login" \\
                https://www3.poolhost.com/index.asp?page=login.asp \\
                -b poolhost_cookies \\
                -c poolhost_cookies};

#

# Then do this to get the next poolid cookie (41149)
my @ham_lines =
  qx {curl -L -X GET "http://www3.poolhost.com/index.asp?page=mypools.asp&poolid=$pool_id&pool_dir=" \\
                 -b poolhost_cookies \\
                 -c poolhost_cookies};

# Then get the xls of the picks for the week
my @picks_lines =
  qx {curl -X GET "http://www3.poolhost.com/index.asp?page=allpicks.asp&exp=1" \\
               -b poolhost_cookies \\
               -c poolhost_cookies > $export_filename.xls};

# Remove the cookie file
unlink "poolhost_cookies"
