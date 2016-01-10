use strict;
use warnings;

use Form::Test;

my $form = Form::Test->new();

$form->process(params => { foo => 77, match => [{},{}]  });

print $form->render;

print $form->field('bar')->render;
