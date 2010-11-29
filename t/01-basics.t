use strict;
use warnings;

use Test::More tests => 105;
use App::Cmd::Tester;

use App::highlight;

## basic highlight behaviour
{
    open_words_txt_as_stdin();

    my $result = test_app('App::highlight' => [ 'ba' ]);

    like($result->stdout, qr/^foo$/ms,      'foo - no match for "ba"'   );
    like($result->stdout, qr/^.+ba.+r$/ms,  'bar - matched "ba"'        );
    like($result->stdout, qr/^.+ba.+z$/ms,  'baz - matched "ba"'        );
    like($result->stdout, qr/^qux$/ms,      'qux - no match for "ba"'   );
    like($result->stdout, qr/^quux$/ms,     'quux - no match for "ba"'  );
    like($result->stdout, qr/^corge$/ms,    'corge - no match for "ba"' );
    like($result->stdout, qr/^grault$/ms,   'grault - no match for "ba"');
    like($result->stdout, qr/^garply$/ms,   'garply - no match for "ba"');
    like($result->stdout, qr/^waldo$/ms,    'waldo - no match for "ba"' );
    like($result->stdout, qr/^fred$/ms,     'fred - no match for "ba"'  );
    like($result->stdout, qr/^plugh$/ms,    'plugh - no match for "ba"' );
    like($result->stdout, qr/^xyzzy$/ms,    'xyzzy - no match for "ba"' );
    like($result->stdout, qr/^thud$/ms,     'thud - no match for "ba"'  );

    is($result->stderr, '', 'nothing sent to sderr');
    is($result->error, undef, 'threw no exceptions');

    restore_stdin();
}

## default = escape
{
    open_words_txt_as_stdin();

    my $result = test_app('App::highlight' => [ '[abcde]+' ]);

    like($result->stdout, qr/^foo$/ms,      'foo - no match for "[abcde]+" (default = escape)'   );
    like($result->stdout, qr/^bar$/ms,      'bar - no match for "[abcde]+" (default = escape)'   );
    like($result->stdout, qr/^baz$/ms,      'baz - no match for "[abcde]+" (default = escape)'   );
    like($result->stdout, qr/^qux$/ms,      'qux - no match for "[abcde]+" (default = escape)'   );
    like($result->stdout, qr/^quux$/ms,     'quux - no match for "[abcde]+" (default = escape)'  );
    like($result->stdout, qr/^corge$/ms,    'corge - no match for "[abcde]+" (default = escape)' );
    like($result->stdout, qr/^grault$/ms,   'grault - no match for "[abcde]+" (default = escape)');
    like($result->stdout, qr/^garply$/ms,   'garply - no match for "[abcde]+" (default = escape)');
    like($result->stdout, qr/^waldo$/ms,    'waldo - no match for "[abcde]+" (default = escape)' );
    like($result->stdout, qr/^fred$/ms,     'fred - no match for "[abcde]+" (default = escape)'  );
    like($result->stdout, qr/^plugh$/ms,    'plugh - no match for "[abcde]+" (default = escape)' );
    like($result->stdout, qr/^xyzzy$/ms,    'xyzzy - no match for "[abcde]+" (default = escape)' );
    like($result->stdout, qr/^thud$/ms,     'thud - no match for "[abcde]+" (default = escape)'  );

    is($result->stderr, '', 'nothing sent to sderr');
    is($result->error, undef, 'threw no exceptions');

    restore_stdin();
}

## basic highlight behaviour - two matches
{
    open_words_txt_as_stdin();

    my $result = test_app('App::highlight' => [ 'ba', 'q' ]);

    like($result->stdout, qr/^foo$/ms,      'foo - no match for "ba" "q"'   );
    like($result->stdout, qr/^.+ba.+r$/ms,  'bar - matched "ba" "q"'        );
    like($result->stdout, qr/^.+ba.+z$/ms,  'baz - matched "ba" "q"'        );
    like($result->stdout, qr/^.+q.+ux$/ms,  'qux - matched "ba" "q"'        );
    like($result->stdout, qr/^.+q.+uux$/ms, 'quux - matched "ba" "q"'       );
    like($result->stdout, qr/^corge$/ms,    'corge - no match for "ba" "q"' );
    like($result->stdout, qr/^grault$/ms,   'grault - no match for "ba" "q"');
    like($result->stdout, qr/^garply$/ms,   'garply - no match for "ba" "q"');
    like($result->stdout, qr/^waldo$/ms,    'waldo - no match for "ba" "q"' );
    like($result->stdout, qr/^fred$/ms,     'fred - no match for "ba" "q"'  );
    like($result->stdout, qr/^plugh$/ms,    'plugh - no match for "ba" "q"' );
    like($result->stdout, qr/^xyzzy$/ms,    'xyzzy - no match for "ba" "q"' );
    like($result->stdout, qr/^thud$/ms,     'thud - no match for "ba" "q"'  );

    is($result->stderr, '', 'nothing sent to sderr');
    is($result->error, undef, 'threw no exceptions');

    restore_stdin();
}

## basic highlight behaviour - color cycle
{
    open_words_txt_as_stdin();

    my $result = test_app('App::highlight' => [ 'a', 'o' ]);

    like($result->stdout, qr/^f(.+)o(.+)\1o\2$/ms,          'foo - matched "a" "o"'       );
    like($result->stdout, qr/^b.+a.+r$/ms,                  'bar - matched "a" "o"'       );
    like($result->stdout, qr/^b.+a.+z$/ms,                  'baz - matched "a" "o"'       );
    like($result->stdout, qr/^qux$/ms,                      'qux - no match for "a" "o"'  );
    like($result->stdout, qr/^quux$/ms,                     'quux - no match for "a" "o"' );
    like($result->stdout, qr/^c.+o.+rge$/ms,                'corge - matched "a" "o"'     );
    like($result->stdout, qr/^gr.+a.+ult$/ms,               'grault - matched "a" "o"'    );
    like($result->stdout, qr/^g.+a.+rply$/ms,               'garply - matched "a" "o"'    );
    like($result->stdout, qr/^w(.+)a(.+)ld(?!\1).+o\2$/ms,  'waldo - no match for "a" "o"');
    like($result->stdout, qr/^fred$/ms,                     'fred - no match for "a" "o"' );
    like($result->stdout, qr/^plugh$/ms,                    'plugh - no match for "a" "o"');
    like($result->stdout, qr/^xyzzy$/ms,                    'xyzzy - no match for "a" "o"');
    like($result->stdout, qr/^thud$/ms,                     'thud - no match for "a" "o"' );

    is($result->stderr, '', 'nothing sent to sderr');
    is($result->error, undef, 'threw no exceptions');

    restore_stdin();
}

## no-escape / regex mode
{
    open_words_txt_as_stdin();

    my $result = test_app('App::highlight' => [ '--no-escape', '[abcde]+' ]);

    like($result->stdout, qr/^foo$/ms,           'foo - no match for "[abcde]+" (no-escape mode)'  );
    like($result->stdout, qr/^.+ba.+r$/ms,       'bar - match for "[abcde]+" (no-escape mode)'     );
    like($result->stdout, qr/^.+ba.+z$/ms,       'baz - match for "[abcde]+" (no-escape mode)'     );
    like($result->stdout, qr/^qux$/ms,           'qux - no match for "[abcde]+" (no-escape mode)'  );
    like($result->stdout, qr/^quux$/ms,          'quux - no match for "[abcde]+" (no-escape mode)' );
    like($result->stdout, qr/^.+c.+org.+e.+$/ms, 'corge - match for "[abcde]+" (no-escape mode)'   );
    like($result->stdout, qr/^gr.+a.+ult$/ms,    'grault - match for "[abcde]+" (no-escape mode)'  );
    like($result->stdout, qr/^g.+a.+rply$/ms,    'garply - match for "[abcde]+" (no-escape mode)'  );
    like($result->stdout, qr/^w.+a.+l.+d.+o$/ms, 'waldo - match for "[abcde]+" (no-escape mode)'   );
    like($result->stdout, qr/^fr.+ed.+$/ms,      'fred - match for "[abcde]+" (no-escape mode)'    );
    like($result->stdout, qr/^plugh$/ms,         'plugh - no match for "[abcde]+" (no-escape mode)');
    like($result->stdout, qr/^xyzzy$/ms,         'xyzzy - no match for "[abcde]+" (no-escape mode)');
    like($result->stdout, qr/^thu.+d.+$/ms,      'thud - match for "[abcde]+" (no-escape mode)'    );

    is($result->stderr, '', 'nothing sent to sderr');
    is($result->error, undef, 'threw no exceptions');

    restore_stdin();
}

## full-line
{
    open_words_txt_as_stdin();

    my $result = test_app('App::highlight' => [ '--full-line', 'u' ]);

    like($result->stdout, qr/^foo$/ms,        'foo - no match for "u" (full-line mode)'   );
    like($result->stdout, qr/^bar$/ms,        'bar - no match for "u" (full-line mode)'   );
    like($result->stdout, qr/^baz$/ms,        'baz - no match for "u" (full-line mode)'   );
    like($result->stdout, qr/^.+qux.+$/ms,    'qux - matched "u" (full-line mode)'        );
    like($result->stdout, qr/^.+quux.+$/ms,   'quux - matched "u" (full-line mode)'       );
    like($result->stdout, qr/^corge$/ms,      'corge - no match for "u" (full-line mode)' );
    like($result->stdout, qr/^.+grault.+$/ms, 'grault - matched "u" (full-line mode)'     );
    like($result->stdout, qr/^garply$/ms,     'garply - no match for "u" (full-line mode)');
    like($result->stdout, qr/^waldo$/ms,      'waldo - no match for "u" (full-line mode)' );
    like($result->stdout, qr/^fred$/ms,       'fred - no match for "u" (full-line mode)'  );
    like($result->stdout, qr/^.+plugh.+$/ms,  'plugh - matched "u" (full-line mode)'      );
    like($result->stdout, qr/^xyzzy$/ms,      'xyzzy - no match for "u" (full-line mode)' );
    like($result->stdout, qr/^.+thud.+$/ms,   'thud - matched "u" (full-line mode)'       );

    is($result->stderr, '', 'nothing sent to sderr');
    is($result->error, undef, 'threw no exceptions');

    restore_stdin();
}

## one-color
{
    open_words_txt_as_stdin();

    my $result = test_app('App::highlight' => [ '--one-color', 'a', 'o' ]);

    like($result->stdout, qr/^f(.+)o(.+)\1o\2$/ms,    'foo - matched "a" "o" (one-color mode)'       );
    like($result->stdout, qr/^b.+a.+r$/ms,            'bar - matched "a" "o" (one-color mode)'       );
    like($result->stdout, qr/^b.+a.+z$/ms,            'baz - matched "a" "o" (one-color mode)'       );
    like($result->stdout, qr/^qux$/ms,                'qux - no match for "a" "o" (one-color mode)'  );
    like($result->stdout, qr/^quux$/ms,               'quux - no match for "a" "o" (one-color mode)' );
    like($result->stdout, qr/^c.+o.+rge$/ms,          'corge - matched "a" "o" (one-color mode)'     );
    like($result->stdout, qr/^gr.+a.+ult$/ms,         'grault - matched "a" "o" (one-color mode)'    );
    like($result->stdout, qr/^g.+a.+rply$/ms,         'garply - matched "a" "o" (one-color mode)'    );
    like($result->stdout, qr/^w(.+)a(.+)ld\1o\2$/ms,  'waldo - no match for "a" "o" (one-color mode)');
    like($result->stdout, qr/^fred$/ms,               'fred - no match for "a" "o" (one-color mode)' );
    like($result->stdout, qr/^plugh$/ms,              'plugh - no match for "a" "o" (one-color mode)');
    like($result->stdout, qr/^xyzzy$/ms,              'xyzzy - no match for "a" "o" (one-color mode)');
    like($result->stdout, qr/^thud$/ms,               'thud - no match for "a" "o" (one-color mode)' );

    is($result->stderr, '', 'nothing sent to sderr');
    is($result->error, undef, 'threw no exceptions');

    restore_stdin();
}


#############################################################################
## helper functions for redirecting STDIN
#############################################################################

my $real_stdin;

sub open_words_txt_as_stdin {
    my $path = __FILE__;
    my $words_txt = $path;
    $words_txt =~ s{01-basics.t}{words.txt};

    $real_stdin = *STDIN;
    close(STDIN);
    open(*STDIN, '<', $words_txt)
        or die "Unable to open $words_txt for reading";
}

sub restore_stdin {
    close(STDIN);
    *STDIN = $real_stdin;
}
