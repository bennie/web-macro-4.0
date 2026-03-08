#!/usr/bin/perl -I/var/www/macrophile.com/lib/

=head1 user-test.pl

This script asks for a user and pass and checks it against the forums 
users for verification.

It does so via the Macro::User::Session object method check();

=cut

use Macro::User::Session;
use Term::Query 'query';

my $m = new Macro::User::Session;

my $user = query('User?');
my $pass = query('Pass?');

print "Returned: ", $m->check($user,$pass), "\n";
