use strict;
use warnings;
#use Path::Tiny qw(path);
#use lib path($0)->absolute->parent->sibling('lib')->stringify;

use Test::More tests => 3;

use_ok 'NotifyURL::ConfigItems';
use_ok 'NotifyURL::Item';
use_ok 'NotifyURL::ItemsValue'
