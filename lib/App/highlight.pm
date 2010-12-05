use strict;
use warnings;

package App::highlight;
use base 'App::Cmd::Simple';

use Try::Tiny;
use Module::Load qw(load);
use Getopt::Long::Descriptive;

my $COLOR_SUPPORT = 1;
my @COLORS;
try {
    load('Term::ANSIColor', 'color');
    @COLORS = map { [ color("bold $_"), color('reset') ] } (
        qw(red green yellow blue magenta cyan)
    );
}
catch {
    $COLOR_SUPPORT = 0;
};

my @NOCOLORS = (
    [ '<<', '>>' ],
    [ '[[', ']]' ],
    [ '((', '))' ],
    [ '{{', '}}' ],
    [ '**', '**' ],
    [ '__', '__' ],
);

sub opt_spec {
    return (
        [
            one_of => [
                [ 'color|c'          => "use terminal color for highlighting (default)" ],
                [ 'nocolor|no-color' => "don't use terminal color"                      ],
            ],
        ],
        [
            one_of => [
                [ 'escape|e'                     => "auto-escape input (default)"          ],
                [ 'noescape|no-escape|regex|n|r' => "don't auto-escape input (regex mode)" ],
            ]
        ],
        [ 'full-line|l' => "highlight the whole matched line"   ],
        [ 'one-color|o' => "use only one color for all matches" ],
        [ 'help|h'      => "display a usage message"            ],
    );
}

sub validate_args {
    my ($self, $opt, $args) = @_;

    if ($opt->{'help'}) {
        my ($opt, $usage) = describe_options(
            $self->usage_desc(),
            $self->opt_spec(),
        );
        print $usage;
        exit;
    }

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
    if ($COLOR_SUPPORT &&
        ($opt->{'color'} || !$opt->{'nocolor'})) {
        @HIGHLIGHTS = @COLORS;
    }
    else {
        @HIGHLIGHTS = @NOCOLORS;
    }

    if (!$COLOR_SUPPORT &&
        ($opt->{'color'} || !$opt->{'nocolor'})) {
        warn "Color support disabled. Install Term::ANSIColor to enable it.\n";
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

=head1 Color Support

If you have Term::ANSIColor installed then the strings will be highlighted
using terminal colors rather than using brackets.

Installing color support by installing Term::ANSIColor is highly reccommended.

=head1 OPTIONS

=head2 color / c

This is the default if Term::ANSIColor is installed.

App::highlight will cycle through the colours:

    red green yellow blue magenta cyan

If you do not have Term::ANSIColor installed and you specify --color or you do
not specify --no-color then you will receive a warning.

=head2 no-color

This is the default if Term::ANSIColor is not installed.

App::highlight will cycle through the brackets:

    <<match>> [[match]] ((match))  {{match}} **match** __match__

The examples in the rest of this document use this mode because showing color
highlighting in POD documentation is not possible.

=head2 escape / e

This is the default and means that the strings passed in will be escaped so
that no special characters exist.

    % cat words.txt | highlight --escape 'ba' '[qux]'
    foo
    <<ba>>r
    <<ba>>z
    qux
    quux
    <<c>>org<<e>>

=head2 noescape / no-escape / n / regex / r

This allows you to specify a regular expression instead of a simple
string.

    % cat words.txt | highlight --no-escape 'ba' '[qux]'
    foo
    <<ba>>r
    <<ba>>z
    [[q]][[u]][[x]]
    [[q]][[u]][[u]][[x]]
    corge

=head2 full-line [l]

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

=head2 one-color [o]

Rather than cycling through multiple colors, this makes highlight always use
the same color for all highlights.

Despite the name "one-color" this interacts with the --no-color option as you
would expect.

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
