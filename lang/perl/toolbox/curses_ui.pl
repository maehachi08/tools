#!/usr/bin/perl
use strict;
use warnings;
use Curses::UI;

my $debug = 0;
my $cui = new Curses::UI(
    -clear_on_exit => 1,
    -color_support => 1,
    -debug => $debug,
);

my @menu = (
    { -label => 'File(Ctrl-x)', 
      -submenu => [
    { -label => 'Exit(Ctrl-q)', -value => \&exit_dialog  }
                  ]
     },
);

sub exit_dialog() {
    my $return = $cui->dialog(
                  -message   => "Do you really want to quit?",
                  -title     => "Are you sure???", 
                  -buttons   => ['yes', 'no'],
    );

    exit(0) if $return;
}

my $menu = $cui->add(
        'menu','Menubar', 
        -menu => \@menu,
        -fg  => "blue",
);

my $win1 = $cui->add(
    'win1', 'Window',
     -border => 1,
     -y    => 1,
     -bfg  => 'red',
);


my $texteditor = $win1->add("text", "TextEditor",
    -text => "Here is some text\n"
             . "And some more"
);


$cui->set_binding(sub {$menu->focus()}, "\cX");
$cui->set_binding( \&exit_dialog , "\cQ");

$texteditor->focus();
$cui->mainloop();
