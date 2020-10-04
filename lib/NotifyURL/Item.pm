package NotifyURL::Item;
use warnings;
use strict;
use 5.010;

use LWP::Simple;
#use Data::Dumper qw(Dumper);

our $VERSION = '1.0';

sub new {
    my $class = shift;
    my $arg_ref = shift;

    my %arg = %{$arg_ref};

    my $search_str = defined $arg{'search_str_before_item'} ? 
                     $arg{'search_str_before_item'} :
                     $arg{'search_str_after_item'}; 

    my $notify_once = 0;

    $notify_once = 1 if (defined $arg{'once_notification'} &&
                         $arg{'once_notification'} eq 'y');

    my $self = {
        'url'         => $arg{'website_url'},
        'search_str'  => $search_str,
        'val_length'  => $arg{'search_str_length_item'},
        'max_val'     => $arg{'max_item_value'},
        'min_val'     => $arg{'min_item_value'},
        'delay_s'     => $arg{'monitor_time_secs'},
        'notify_once' => $notify_once,
    };

    return bless $self, $class;
}

sub start_monitoring {
    my $self = shift;

    my $url = $self->{'url'};
    my $search_str = $self->{'search_str'};
    my $search_len = length($search_str);
    my $val_len = $self->{'val_length'};

    my $max_val = $self->{'max_val'};
    my $min_val = $self->{'min_val'};

    my $notify_once = $self->{'notify_once'};

    my $delay_secs = $self->{'delay_s'};   

    my $run = 1;

    my $pid = fork();

    die "Error, could not create child process...url: $url\n" unless (defined $pid);

    if ($pid == 0) {

        while ($run) {

            my $url_src_code = get($url);
            my $start_index = index($url_src_code, $search_str);

            my $val_to_chk = substr($url_src_code, 
                                    $start_index + $search_len, 
                                    $val_len);

            if ($val_to_chk >= $min_val && $val_to_chk <= $max_val) {
                # print "url: $url - alert notification: value of monitoring item is: $val_to_chk which is now between range: $min_val - $max_val\n";
                if ($notify_once) {
                    # TODO: Send notification(via email or other ways) once and then exit the monitoring loop
                    $run = 0;
                } else {
                    # Keep sending notification every time? need to check config option: notification_time_secs
                }
            } else {
#                print "url: $url - value of monitoring item is: $val_to_chk\n";
            }

            sleep($delay_secs);
        }

        exit(0);
    }
}

sub notify {
# email notification
}

1;

