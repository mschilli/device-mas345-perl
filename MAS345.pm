###########################################
package Device::MAS345;
###########################################
use strict;
use warnings;
use Device::SerialPort;
use Log::Log4perl qw(:easy);

our $VERSION = "0.01";

###########################################
sub new {
###########################################
    my($class, %options) = @_;

    my $self = {
        port     => "/dev/ttyS0",
        baudrate => 600,
        bytes    => 14,
        pause    => .5,
        databits => 7,
        %options,
    };

    bless $self, $class;
    $self->reset();

    return $self;
}

###########################################
sub error {
###########################################
    my($self, $err) = @_;

    $self->{error} = $err if defined $err;
    return $self->{error};
}

###########################################
sub read {
###########################################
    my($self) = @_;

    my $data;

    eval {
        $data = $self->read_raw();
    };

    if($@) {
        my $err = "read_raw failed ($@)";
        ERROR $err;
        $self->error($err);
        return undef;
    }

    if($data =~ /(\w+)\s+(\w+)\s+(\w+)/) {
        return ($1, $2, $3);
    }

    my $err = "Unrecognized response: $data";
    ERROR $err;
    $self->error($err);
    
    return undef;
}

###########################################
sub read_raw {
###########################################
    my($self) = @_;

    DEBUG "Purging";
    $self->{serial}->purge_all() || 
        LOGDIE "Purge failed ($!)";

    DEBUG "Sending newline";
    $self->{serial}->write("\n") || 
        LOGDIE "Send of newline failed";

    DEBUG "Waiting $self->{pause} seconds";
    select(undef, undef, undef, $self->{pause});

    DEBUG "Reading response";
    my($count, $data) = $self->{serial}->read($self->{bytes});

    DEBUG "Received $count bytes";
    if($count != $self->{bytes}) {
        LOGDIE "Read $self->{bytes}, got only $count";
    }

    return $data;
}

###########################################
sub reset {
###########################################
    my($self) = @_;

    $self->{serial} = Device::SerialPort->new(
            $self->{port}, undef);

    $self->{serial}->baudrate($self->{baudrate}) or
        LOGDIE "Setting baudrate to $self->{baudrate} failed";

    $self->{serial}->databits($self->{databits}) or
        LOGDIE "Setting databits to $self->{databits} failed";
}

1;

__END__

=head1 NAME

Device::MAS345 - Reading the Mastech MAS-345 Multimeter

=head1 SYNOPSIS

  use Device::MAS345;

  my $mas = Device::MAS345->new( port => "/dev/ttyS0" );

  my($mode, $val, $unit) = $mas->read() or
     die "Cannot read (", $mas->error(), ")";

=head1 DESCRIPTION

C<Device::MAS345> reads data from a Mastech MAS-345 multimeter
connected to the computer's serial port.

This cheap (less than $50) multimeter measures voltage, current, 
temperature, resistance, capacity, and features a serial cable
to hook it up to a PC.

Using C<Device::MAS345>, you can connect to the multimeter and 
read out the currently displayed value, along with the selected
mode and a units character.

The constructor can be called without arguments. The optional
C<ports> parameter defaults to C</dev/ttyS0>, the first
serial port.

If you want to run this as a non-root user, make sure that

    ls -l /dev/ttyS0

(or whatever serial port the multimeter is connected to) is
read/writeable by the user.

The multimeter has to be turned on for the connection to succeed.

=head1 LEGALESE

Copyright 2007 by Mike Schilli, all rights reserved.
This program is free software, you can redistribute it and/or
modify it under the same terms as Perl itself.

=head1 AUTHOR

2007, Mike Schilli <cpan@perlmeister.com>
