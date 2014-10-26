package Catalyst::Controller::FormBuilder::MultiForm;

our $VERSION = '0.02';

use strict;
use warnings;

use base qw| Catalyst::Controller::FormBuilder |;

my %DEFAULTS = 
(
  stash_name    => 'forms',
  template_type => 'TT',
  action        => undef,
);

sub __setup
{
  my $self   = shift;
  my $class  = ref $self;
  my $config = $self->config->{'Controller::FormBuilder::MultiForm'} || {};
  
  # Add config options to our accesor
  foreach my $option ( keys %DEFAULTS )
  { 
    __PACKAGE__->mk_accessors( "_$option" );
    $self->set( "_$option", $config->{$option} || $DEFAULTS{$option} ); 
  }
  
  # Set the action class based on our package name and template type unless
  # one was already set already
  $self->_action( __PACKAGE__ . '::Action::' . $self->_template_type ) unless defined $self->_action;
  
  # Call the parent's setup method
  $self->SUPER::__setup();
  
  # Override the parent's action class, so that it goes to our multiform action instead
  $self->_fb_setup->{action} = $self->_action;
}

1;

__END__

=head1 NAME

Catalyst::Controller::FormBuilder::MultiForm - Multiple forms per template with Catalyst::Controller::FormBuilder

=head1 SYNOPSIS

In your controller:

  use base 'Catalyst::Controller::FormBuilder::MultiForm';
  
  sub foo : Local Form {
    my ($self, $c) = @_;
    
    # Get a local copy of the "foo" form
    my $foo_form = $self->formbuilder;
    
    # Forward to the "bar" action to include the "bar" form, and get a copy of it
    my $bar_form = $c->forward('bar');
    
    # Do stuff with the "foo" or "bar" form results
    # ...
  }
  
  sub bar : Local Form {
    my ($self, $c) = @_;
    return $self->formbuilder;
  }

In your C<foo.fb> FormBuilder configuration file:

  name: my_foo_form

In your C<bar.fb> FormBuilder configuration file:

  name: my_bar_form

In your template for the C<foo> action (Template Toolkit):

  <!-- Display the "foo" form -->
  [% forms.my_foo_form.FormBuilder.render %]
  
  <!-- Display the "bar" form -->
  [% forms.my_bar_form.FormBuilder.render %]

=head1 DESCRIPTION

This module allows you to access multiple FormBuilder objects per template when
using Catalyst::Controller::FormBuilder (see L<Catalyst::Controller::FormBuilder>
for more information).

By default, Catalyst::Controller::FormBuilder provides a set of variables in the
stash that you can use to access your form (default: C<$c-E<gt>stash-E<gt>{FormBuilder}>
and C<$c-E<gt>stash-E<gt>{formbuilder}>).

If you forward to another C<:Form> action, that action's FormBuilder object will
replace the FormBuilder object in your calling action.  This allows you to forward to
other actions for building form details yet keep your form handling in the calling action,
and is quite handy.

However, it prevents you from forwarding to other C<:Form> actions for the purpose
of building multiple FormBuilder objects for use in a single page.

This module allows you to keep a copy of the FormBuilder object for each C<:Form> action
you forward to in the stash, so that you can access multiple forms inside one template.  
Each form is kept in a stash variable (default: C<$c-E<gt>{forms}>) and can be accessed
by the name of the form (as set in your form configuration).

For example, if you named your form C<foo_edit> in your form configuration, 
you could access this form by name with the following stash variables:

  # Access the formbuilder object for the "foo_edit" form 
  $c->stash->{forms}->{foo_edit}->{FormBuilder}
  
  # Access the formbuilder data for the "foo_edit" form
  $c->stash->{forms}->{foo_edit}->{formbuilder}

If you wish to use the default behavior, just use the regular FormBuilder stash values:

  $c->stash->{FormBuilder}
  $c->stash->{formbuilder}

Since you can use both behaviors, it is safe to use this module as your base controller
without having to modify your existing single form FormBuilder code and templates.  Just
don't access the form by name, and you won't get the multiform behavior.

=head1 TEMPLATES

For a description of templating systems supported, see 
L<Catalyst::Controller::FormBuilder/"TEMPLATES">.

=head2 Template::Toolkit

L<Template::Toolkit|Template::Toolkit> and L<HTML::Mason|HTML::Mason> are 
pretty straightforward, and work as described above by just accessing the stash.

Example of rendering a form named C<foo> in L<Template::Toolkit|Template::Toolkit>:

  [% forms.foo.FormBuilder.render %]

=head2 HTML::Mason

Example of rendering a form named C<foo> in L<HTML::Mason|HTML::Mason>:

  <% $forms->{foo}->{FormBuilder}->render %>

=head2 HTML::Template

If you wish to access a form by name with L<HTML::Template|HTML::Template>, you can
do so by prefixing the usual FormBuilder HTML::Template variables with the name
of your form, like C<[form name]-[formbuilder template variable]>.

See L<CGI::FormBuilder::Template::HTML> for information about FormBuilder
template variables in HTML::Template..

Example of rendering a form named C<foo> in L<HTML::Template|HTML::Template>:

  <tmpl_var foo-form-start>
  <tmpl_var foo-form-statetags>
  <tmpl_var foo-label-username> <tmpl_var foo-field-username>
  <tmpl_var foo-label-password> <tmpl_var foo-field-password>
  <tmpl_var foo-form-submit>
  <tmpl_var foo-form-end>

=head1 CONFIGURATION

For a details on how to set configuration options for FormBuilder, see 
L<Catalyst::Controller::FormBuilder/"CONFIGURATION">.

If you wish to set any of the configuration options specific to MultiForm, 
you would do so as follows:

  MyApp->config
  (
    # Define config options specific to MultiForm
    'Controller::FormBuilder::MultiForm' => 
    {
      stash_name => 'lots_of_forms_in_here',
      template_type => 'TT',
    }
    # Define any regular FormBuilder config options
    'Controller::FormBuilder' => 
    {
      # ..
    }
  );

The following configuration options are available for MultiForm:

=over

=item C<stash_name>

Defines the name of the stash variable to use for holding all of your forms.

Not applicable for HTML::Template view.

Please note that this option does not effect FormBuilder's stash_name option in any way.  You are safe to set each option as you please in the appropriate configuration section.

Default: C<forms>

=back

=over

=item C<template_type>

Defines the Catalyst View that the stash will be prepared for.

Possible values are: C<HTML::Template>, C<Mason> or C<TT>.

Default: C<TT>

=back

=head1 CAVEATS

=head2 Form Name is Required

You must provide a form name in your form configuration for this to work.
If your form is not named, then it will not be included in the list of
forms.

=head2 Form Name Uniqueness

Each form name must be unique.  If you forward to more than one form with
the same name, the form data will be overwritten.

=head2 Field Name Uniqueness

Be careful with field names when using the module.  Clashing field names
will result in data from one form bleeding in to an other.  This is just
the nature of POST / GET.  

To get around this, FormBuilder itself would have to prefix the form name 
on each field id natively in its rendering methods, which it currently
does not.

=head2 Multiple Form on the Fly

It would be handy to be able to generate multiple forms on the fly with
this module.  For example, you could make an AJAX call to generate a series
of "create" forms on the fly.

However, because L<CGI::FormBuilder|CGI::FormBuilder> does not yet support 
unique field names on the fly, this functionality will not be available in 
MultiForm.

=head1 SEE ALSO

L<Catalyst::Controller::FormBuilder|Catalyst::Controller::FormBuilder>, 
L<CGI::FormBuilder|CGI::FormBuilder>, 
L<Catalyst::Manual|Catalyst::Manual>

=head1 AUTHOR

Danny Warren <perl@dannywarren.com>

=head1 CREDITS

Thanks to Juan Camacho for his help with this, and for his great
Catalyst::Controller::FormBuilder module.

=head1 LICENSE

Copyright (c) 2007 Danny Warren. All rights reserved.

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
