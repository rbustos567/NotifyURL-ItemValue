package NotifyURL::ConfigItems;
use warnings;
use strict;
use 5.010;

use Config::Tiny;
#use Data::Dumper qw(Dumper);

our $VERSION = '1.0';

use constant CONF_MAIN_SECTION => "website_"; 
use constant CONF_FILE         => "config/url_items_conf.ini";

my %config_rules = ( 'website_url'            => {
                                                     'type'     => 'mandatory',
                                                 },
                     'search_str_before_item' => {
                                                     'type'     => 'alternative',
                                                     'alt_opt'  => 'search_str_after_item',
                                                 },
                     'search_str_after_item'  => {
                                                     'type'     => 'alternative',
                                                     'alt_opt'  => 'search_str_before_item'
                                                 },
                     'search_str_length_item' => {
                                                     'type'     => 'mandatory',
                                                 },
                     'monitor_time_secs'      => {
                                                     'type'     => 'mandatory',
                                                 },
                     'max_item_value'         => {
                                                     'type'     => 'mandatory',
                                                 },
                     'min_item_value'         => {
                                                     'type'     => 'mandatory',
                                                 },
                     'notification_time_secs' => {
                                                     'type'     => 'alternative',
                                                     'alt_opt'  => 'once_notification',
                                                 },
                     'once_notification' =>      {
                                                     'type'     => 'alternative',
                                                     'alt_opt'  => 'notification_time_secs',
                                                 },

                    );



my $instance = undef;

#TODO: Add error handiling and exceptions
sub new {

    my $class = shift;

    unless ( defined $instance) {

        my $config = undef;
        eval { $config = Config::Tiny->read( CONF_FILE, 'utf8' ) };

        if ($@) {
            die "Error while trying to open config file: ". CONF_FILE;
        }

        my $self = {
            'config'     => $config,
            'items'      => undef,
        };

        $instance = bless $self, $class;
    }

    return $instance;
}

sub init {
    my $self = shift;

    my %error = _validate_config($self);

    return %error;
}

sub get_num_items {
    my $self = shift;

    return $self->{'items'} ? scalar keys %{$self->{'items'}} : 0;
}

sub get_item_opts_by_index {
    my $self = shift;
    my $index = shift;

    if ($self->{'items'}->{$index}) {
        return $self->{'items'}->{$index};
    }

    return undef;
}

sub _validate_config {
    my $self = shift;

    my %res = ();

    my $config = $self->{config};
    my $item_i = 0;

    foreach my $website_key (sort keys %$config) {
        if ( index($website_key, CONF_MAIN_SECTION) > -1) {

            %res = _validate_config_section($config->{$website_key}, $website_key);
                
            if ($res{'error'}) {
                last;
            } else {
                $self->{'items'}->{$item_i} = $res{item};             
                $item_i++;
            }
        }
    }

    return %res;
}

sub _validate_config_section {
    my $arg_ref = shift;
    my $cfg_sect = shift;

    my %res = (
                  'error'     => 0,
                  'err_msg'   => undef,
                  'item'      => undef,
              );

    my %config_section = %{$arg_ref};

    foreach my $conf_rule (keys %config_rules) {

        if ($config_rules{$conf_rule}{'type'} eq 'mandatory') {
            unless (defined $config_section{$conf_rule} && 
                            $config_section{$conf_rule} ne '') {
            
                $res{'error'} = 1;
                $res{'err_msg'} = "Missing mandatory option: " . $conf_rule . " in section: " . $cfg_sect;

                last;
            } else {
                $res{'item'}{$conf_rule} = $config_section{$conf_rule};
            }

        } elsif ($config_rules{$conf_rule}{'type'} eq 'alternative') {
            unless ( defined $config_section{$conf_rule} &&
                             $config_section{$conf_rule} ne '') {

                my $alt_rule = $config_rules{$conf_rule}{'alt_opt'}; 

                unless ( defined $config_section{$alt_rule} &&
                                 $config_section{$alt_rule} ne '') {

                    $res{'error'} = 1;
                    $res{'err_msg'} = "Could not find at least one of these mandatory options: " . $conf_rule . ", " . $alt_rule . " in section: " . $cfg_sect;

                    last;

                } else {
                    $res{'item'}{$alt_rule} = $config_section{$alt_rule}
                }

            } else {
                $res{'item'}{$conf_rule} = $config_section{$conf_rule}
            } 

        }
    }

    return %res;
}

1;
