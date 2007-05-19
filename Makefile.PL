######################################################################
# Makefile.PL for Device::MAS345
# 2007, Mike Schilli <cpan@perlmeister.com>
######################################################################
use ExtUtils::MakeMaker;
WriteMakefile(
    'NAME'         => 'Device::MAS345',
    'VERSION_FROM' => 'MAS345.pm', # finds $VERSION
    'PREREQ_PM'    => {
        Log::Log4perl      => 1.0,
        Device::SerialPort => 1,
    }, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?    ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM => 'MAS345.pm',
       AUTHOR     => 'Mike Schilli <cpan@perlmeister.com>') : ()),
);
