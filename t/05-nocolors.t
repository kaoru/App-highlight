use strict;
use warnings;

use File::Basename;
use lib dirname(__FILE__);

use Test::More tests => 15;
use App::Cmd::Tester;
use Test::AppHighlightWords;

use App::highlight;

## no-color
{
    open_words_txt_as_stdin();

    my $result = test_app('App::highlight' => [ '--no-color', 'a', 'o' ]);

    like($result->stdout, qr/^f\[\[o\]\]\[\[o\]\]$/ms,  'foo - matched "a" "o"'       );
    like($result->stdout, qr/^b<<a>>r$/ms,              'bar - matched "a" "o"'       );
    like($result->stdout, qr/^b.+a.+z$/ms,              'baz - matched "a" "o"'       );
    like($result->stdout, qr/^qux$/ms,                  'qux - no match for "a" "o"'  );
    like($result->stdout, qr/^quux$/ms,                 'quux - no match for "a" "o"' );
    like($result->stdout, qr/^c\[\[o\]\]rge$/ms,        'corge - matched "a" "o"'     );
    like($result->stdout, qr/^gr<<a>>ult$/ms,           'grault - matched "a" "o"'    );
    like($result->stdout, qr/^g<<a>>rply$/ms,           'garply - matched "a" "o"'    );
    like($result->stdout, qr/^w<<a>>ld\[\[o\]\]$/ms,    'waldo - matched "a" "o"'     );
    like($result->stdout, qr/^fred$/ms,                 'fred - no match for "a" "o"' );
    like($result->stdout, qr/^plugh$/ms,                'plugh - no match for "a" "o"');
    like($result->stdout, qr/^xyzzy$/ms,                'xyzzy - no match for "a" "o"');
    like($result->stdout, qr/^thud$/ms,                 'thud - no match for "a" "o"' );

    is($result->stderr, '', 'nothing sent to sderr');
    is($result->error, undef, 'threw no exceptions');

    restore_stdin();
}
