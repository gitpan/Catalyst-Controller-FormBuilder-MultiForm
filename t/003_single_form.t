# -*- perl -*-

# t/003_single_form.t
#   verify that we can access and submit a single form by name using 
#   MultiForm functionality

use Test::More tests => 9;
use FindBin;

use lib "$FindBin::Bin/lib";
use Test::WWW::Mechanize::Catalyst 'TestApp';

my $mech = Test::WWW::Mechanize::Catalyst->new;
my $page = "test/one_form";

$mech->get_ok( "http://localhost/$page", "GET /$page" );

my $foo_form = $mech->form_name('foo');
ok( $foo_form, "Form found" ) or BAIL_OUT( "Can't do anything without a form!" );

my $foo_one = $foo_form->find_input( 'foo_one' );
ok( $foo_one, "First input field found");

my $foo_two = $foo_form->find_input( 'foo_two' );
ok( $foo_two, "Second input field found");

$foo_one->value('foo_one_value');
is( $foo_one->value, 'foo_one_value', "Set first input field value" );

$foo_two->value('foo_two_value');
is( $foo_two->value, 'foo_two_value', "Set second input field value" );

$mech->submit;

like( $mech->content, qr/form:foo/, "Form submitted correctly" );
like( $mech->content, qr/foo_one:foo_one_value/, "First input value submitted correctly" );
like( $mech->content, qr/foo_two:foo_two_value/, "Second input value submitted correctly" );