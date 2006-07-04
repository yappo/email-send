package Email::Send::Sendmail;
# $Id: Sendmail.pm,v 1.7 2006/01/28 23:02:44 cwest Exp $
use strict;

use Return::Value;

use vars qw[$SENDMAIL $VERSION];

$VERSION   = '2.04';

sub is_available {
    my $class = shift;
    my $status = '';
       $status = "No Sendmail found" unless $class->_find_sendmail;
    return success $status;
}

sub _find_sendmail {
    my $class = shift;
    return $SENDMAIL if defined $SENDMAIL;

    my @path = split /:/, $ENV{PATH};
    my $sendmail;
    for (@path) {
        if ( -x "$_/sendmail" ) {
            $sendmail = "$_/sendmail";
            last;
        }
    }
    return $sendmail;
}

sub send {
    my ($class, $message, @args) = @_;
    my $mailer = $class->_find_sendmail;
    return failure "Found $mailer but cannot execute it"
        unless -x $mailer;
    open SENDMAIL, "| $mailer -t -oi @args"
        or return failure "Error executing $mailer: $!";
    print SENDMAIL $message->as_string
        or return failure "Error printing via pipe to $mailer: $!";
    close SENDMAIL;
    return success;
}

1;

__END__

=head1 NAME

Email::Send::Sendmail - Send Messages using sendmail

=head1 SYNOPSIS

  use Email::Send;

  Email::Send->new({mailer => 'Sendmail'})->send($message);

=head1 DESCRIPTION

This mailer for C<Email::Send> uses C<sendmail> to send a message. It
I<does not> try hard to find the executable. It just calls
C<sendmail> and expects it to be in your path. If that's not the
case, or you want to explicitly define the location of your executable,
alter the C<$Email::Send::Sendmail::SENDMAIL> package variable.

  $Email::Send::Sendmail::SENDMAIL = '/usr/sbin/sendmail';

Any arguments passed to C<send> will be passed to C<sendmail>. The
C<-t -oi> arguments are sent automatically.

=head1 SEE ALSO

L<Email::Send>,
L<perl>.

=head1 AUTHOR

Casey West, <F<casey@geeknest.com>>.

=head1 COPYRIGHT

  Copyright (c) 2004 Casey West.  All rights reserved.
  This module is free software; you can redistribute it and/or modify it
  under the same terms as Perl itself.

=cut