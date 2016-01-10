use strict;
use warnings;

use Form::Fixtures;

my $form = Form::Fixtures->new();

$form->process(
    params => { fixture => [ {}, {}, {}, {}, {}, {}, {}, {}, {}, {} ] } );

print $form->render;

print "\n\n+++++++++++++++++++++++++++++++++++++++++++++++++++++\n\n";

print $form->field('fixture')->field(0)->render;

print "\n\n------+++++++++++++++++++++++++++++++++++++++++++++++\n\n";

print $form->field('fixture')->field(0)->field('home')->render;

print "\n\n------+++++++++++++++++++++++++++++++++++++++******++\n\n";

print $form->field('fixture')->field(0)->field('home')->field('name')->render;

