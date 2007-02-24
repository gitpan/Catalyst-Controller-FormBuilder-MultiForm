

use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME         => 'Catalyst::Controller::FormBuilder::MultiForm',
    VERSION_FROM => 'lib/Catalyst/Controller/FormBuilder/MultiForm.pm', 
    AUTHOR       => 'Danny Warren (perl@dannywarren.com)',
    ABSTRACT     => 'Multiple forms per template with FormBuilder',
    PREREQ_PM    => {
                     'Test::Simple' => 0.44,
                     'Catalyst::Controller::FormBuilder' => 0.02,
                    },
);
