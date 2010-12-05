use strict;
use warnings;

package App::highlight;
use base 'App::Cmd::Simple';

use Term::ANSIColor ':constants';

my @NOCOLORS = (
    [ '<<', '>>' ],
    [ '[[', ']]' ],
    [ '((', '))' ],
    [ '{{', '}}' ],
    [ '**', '**' ],
    [ '__', '__' ],
);

my @COLORS = map { [ (BOLD $_), RESET ] } (
    RED, GREEN, YELLOW, BLUE, MAGENTA, CYAN
);

sub opt_spec {
    return (
        [ 'color|c'                         => "use terminal color for highlighting (default)" ],
        [ 'nocolor|no-color'                => "don't use terminal color"                      ],
        [ 'escape|e'                        => "auto-escape input (default)"                   ],
        [ 'noescape|no-escape|regex|n|r'    => "don't auto-escape input (regex mode)"          ],
        [ 'full-line|l'                     => "highlight the whole matched line"              ],
        [ 'one-color|o'                     => "use only one color for all matches"            ],
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

    my @matches;
    if (scalar @$args) {
        if ($opt->{'escape'} || !$opt->{'noescape'}) {
            @$args = map { "\Q$_" } @$args;
        }
        @matches = @$args;
    }

    my @HIGHLIGHTS;
    if ($opt->{'color'} || !$opt->{'nocolor'}) {
        @HIGHLIGHTS = @COLORS;
    }
    else {
        @HIGHLIGHTS = @NOCOLORS;
    }

    if ($opt->{'one_color'}) {
        @HIGHLIGHTS = ($HIGHLIGHTS[0]);
    }

    while (<STDIN>) {
        my $i = 0;
        foreach my $m (@matches) {
            if ($opt->{'full_line'}) {
                if (m/$m/) {
                    s/^/$HIGHLIGHTS[$i][0]/;
                    s/$/$HIGHLIGHTS[$i][1]/;
                }
            }
            else {
                s/($m)/$HIGHLIGHTS[$i][0] . $1 . $HIGHLIGHTS[$i][1]/ge;
            }

            $i++;
            $i %= @HIGHLIGHTS;
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
    <<ba>>r
    <<ba>>z
    qux
    quux
    corge

If you give multiple match parameters highlight will highlight each of them in
a different color.

    % cat words.txt | highlight ba qu
    foo
    <<ba>>r
    <<ba>>z
    [[qu]]x
    [[qu]]ux
    corge

Note that brackets are not used to highlight the words, Term::ANSIColor
terminal highlighting is used.

=head1 OPTIONS

=head1 escape / e

This is the default and means that the strings passed in will be escaped so
that no special characters exist.

    % cat words.txt | highlight --escape 'ba' '[qux]'
    foo
    <<ba>>r
    <<ba>>z
    qux
    quux
    <<c>>org<<e>>

=head1 noescape / no-escape / n / regex / r

This allows you to specify a regular expression instead of a simple
string.

    % cat words.txt | highlight --no-escape 'ba' '[qux]'
    foo
    <<ba>>r
    <<ba>>z
    [[q]][[u]][[x]]
    [[q]][[u]][[u]][[x]]
    corge

=head1 full-line [l]

This makes highlight always highlight full lines of input, even when
the full line is not matched.

    % cat words.txt | highlight --full-line u
    foo
    bar
    baz
    <<qux>>
    <<quux>>
    corge

Note this is similar to '--no-escape "^.*match.*$"' but probably much
more efficient.

=head1 one-color [o]

Rather than cycling through multiple colors, this makes highlight always use
the same color for all highlights.

    % cat words.txt | highlight --one-color ba qu
    foo
    <<ba>>r
    <<ba>>z
    <<qu>>x
    <<qu>>ux
    corge

=head1 Copyright

Copyright (C) 2010 Alex Balhatchet

=head1 Author

Alex Balhatchet (kaoru@slackwise.net)

=cut
