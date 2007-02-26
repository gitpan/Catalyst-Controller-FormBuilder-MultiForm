# -*- perl -*-

# t/004_multiple_forms.t
#   verify that we can access and submit multiple forms by name using 
#   MultiForm functionality

use Test::More tests => 18;
use FindBin;

use lib "$FindBin::Bin/lib";
use Test::WWW::Mechanize::Catalyst 'TestApp';

my $mech = Test::WWW::Mechanize::Catalyst->new;
my $page = "test/two_forms";

$mech->get_ok( "http://localhost/$page", "GET /$page" );

my $foo_form = $mech->form_name('foo');
ok( $foo_form, "First form found" ) or BAIL_OUT( "Can't do anything without a form!" );

my $foo_one = $foo_form->find_input( 'foo_one' );
ok( $foo_one, "First input field in first form found");

my $foo_two = $foo_form->find_input( 'foo_two' );
ok( $foo_two, "Second input field in first form found");

$foo_one->value('foo_one_value');
is( $foo_one->value, 'foo_one_value', "Set first input field value in first form" );

$foo_two->value('foo_two_value');
is( $foo_two->value, 'foo_two_value', "Set second input field value in first form" );

$mech->submit;

like( $mech->content, qr/form:foo/, "First form submitted correctly" );
like( $mech->content, qr/foo_one:foo_one_value/, "First input value in first form submitted correctly" );
like( $mech->content, qr/foo_two:foo_two_value/, "Second input value in first form submitted correctly" );


$mech->get_ok( "http://localhost/$page", "GET /$page" );

my $bar_form = $mech->form_name('bar');
ok( $bar_form, "Second form found" ) or BAIL_OUT( "Can't do anything without a form!" );

my $bar_one = $bar_form->find_input( 'bar_one' );
ok( $bar_one, "First input field in second form found");

my $bar_two = $bar_form->find_input( 'bar_two' );
ok( $bar_two, "Second input field in second form found");

$bar_one->value('bar_one_value');
is( $bar_one->value, 'bar_one_value', "Set first input field value in second form" );

$bar_two->value('bar_two_value');
is( $bar_two->value, 'bar_two_value', "Set second input field value in second form" );

$mech->submit;

like( $mech->content, qr/form:bar/, "Second form submitted correctly" );
like( $mech->content, qr/bar_one:bar_one_value/, "First input value in second form submitted correctly" );
like( $mech->content, qr/bar_two:bar_two_value/, "Second input value in second form submitted correctly" );