package NotifyURL::ItemsValue;
use warnings;
use strict;
use 5.010;

use NotifyURL::ConfigItems;
use NotifyURL::Item;
#use Data::Dumper qw(Dumper);

our $VERSION = '1.0';

my $instance = undef;

#TODO: Add error handiling and exceptions
# Add log
# Add verbose
sub new {
    my $class = shift;

    unless (defined $instance) {

        my $self = {
            config => undef,
            items  => undef,
        };

        $instance = bless $self, $class;
    }

    return $instance;
}

sub init {
    my $self = shift;

    my $config = new NotifyURL::ConfigItems();

    my %error = $config->init();

    if ($error{'error'}) {
        die $error{'err_msg'};
    }

    my $total_items = $config->get_num_items();
    my $i;

    for $i (0..$total_items - 1) {
        my $item_opts = $config->get_item_opts_by_index($i);

        my $item = new NotifyURL::Item($item_opts);

        push @{$self->{'items'}}, $item;
    }
}

sub run {
    my $self = shift;

    foreach my $item ( @{$self->{'items'}} ) {
        $item->start_monitoring();
    }
}

1;
