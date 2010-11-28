use strict;
use warnings;

package App::highlight;
use base 'App::Cmd::Simple';

use Term::ANSIColor ':constants';

my @COLORS = map { BOLD $_ } (
    RED, GREEN, YELLOW, BLUE, MAGENTA, CYAN
);

my $RESET = RESET;

sub opt_spec {
    return (
        [ 'no-escape|n' => "don't auto-escape input"          ],
        [ 'full-line|l' => "highlight the whole matched line" ],
    );
}

sub validate_args {
    my ($self, $opt, $args) = @_;

    if (!@$args) {
        $self->usage_error(
            "No arguments given!\n" .
            "What do you want me to highlight?\n"
        );
    }

    return;
}

sub execute {
    my ($self, $opt, $args) = @_;

    my @matches = (".+");
    if (scalar @$args) {
        if (!$opt->{'no_escape'}) {
            @$args = map { "\Q$_" } @$args;
        }
        @matches = @$args;
    }

    while (<STDIN>) {
        my $i = 0;
        foreach my $m (@matches) {
            if ($opt->{'full_line'}) {
                if (m/$m/) {
                    s/^/$COLORS[$i]/;
                    s/$/$RESET/;
                }
            }
            else {
                s/($m)/$COLORS[$i] . $1 . $RESET/ge;
            }

            $i++;
            $i %= @COLORS;
        }
        print;
    }

    return;
}

1;

__END__

=head1 NAME

App::highlight - simple grep-like highlighter app

=head1 SYNOPSIS

highlight is similar to grep, except that instead of removing
non-matched lines it simply highlights words or lines which are
matched.

    % cat words.txt
    foo
    bar
    baz
    qux
    quux
    corge

    % cat words.txt | grep ba
    bar
    baz

    % cat words.txt | highlight ba
    foo
    >>ba<<r
    >>ba<<z
    qux
    quux
    corge

Note that angle brackets are not used to highlight the words,
Term::ANSIColor terminal highlighting is used.

=head1 OPTIONS

=head1 no-escape [n]

This allows you to specify a regular expression instead of a simple
string.

    % cat words.txt | highlight --no-escape '[abcde]+'
    foo
    >>ba<<r
    >>ba<<z
    qux
    quux
    >>c<<org>>e<<

=head1 full-line

This makes highlight always highlight full lines of input, even when
the full line is not matched.

    % cat words.txt | highlight --full-line u
    foo
    bar
    baz
    >>qux<<
    >>quux<<
    corge

Note this is similar to '--no-escape "^.*match.*$"' but probably much
more efficient.

=head1 Copyright

Copyright (C) 2010 Alex Balhatchet

=head1 Author

Alex Balhatchet (kaoru@slackwise.net)

=cut
