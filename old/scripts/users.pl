#!/usr/bin/perl -Ilib

use Macro::User::Admin;
use Term::Query qw/query/;

my $admin = new Macro::User::Admin;

print "Creating a new user...\n";

my $user  = query('New User? : ');
my $pass  = query('Password? : ');
my $email = query('Email?    : ');

my $ret = $admin->adduser({username=>$user,password=>$pass,email=>$email});

print "The creation of $user with password $pass returned $ret\n";
