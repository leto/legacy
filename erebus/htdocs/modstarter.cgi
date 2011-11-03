#!/usr/bin/perl -w

use lib "/export/domains/leto.net//perl5lib";
use ModStarter;
use CGI::Carp qw(fatalsToBrowser);
use strict;

my $app = ModStarter->new();
$app->run();

