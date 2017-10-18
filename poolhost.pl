#!/usr/bin/perl
use strict;
use warnings;

use Getopt::Long qw(GetOptions);

sub usage {
  print "Usage: poolhost -u <username> -p <password> [-out <filename>]\n";
  exit;
}

my $username;
my $password;
my $export_filename = "picks.xls";
my $help = 0;

GetOptions('u=s' => \$username,
           'p=s' => \$password,
           'out=s' => \$export_filename,
           'h!' => \$help,
) or usage();

if ($help) {
  usage();
}

usage() unless defined $username;
usage() unless defined $password;

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

# Then do this to get the next poolid cookie
my @ham_lines =
  qx {curl -L -X GET "http://www3.poolhost.com/index.asp?page=mypools.asp&poolid=41149&pool_dir=" \\
                 -b poolhost_cookies \\
                 -c poolhost_cookies};

# Then get the xls of the picks for the week
my @picks_lines =
  qx {curl -X GET "http://www3.poolhost.com/index.asp?page=allpicks.asp&exp=1" \\
               -b poolhost_cookies \\
               -c poolhost_cookies > picks.xls};

# Remove the cookie file
unlink "poolhost_cookies"
