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


# メニューバー
my $menu = $cui->add(
        'menu','Menubar', 
        -menu => \@menu,
        -fg  => "blue",
);



# ボタン
my $button_window = $cui->add(
    'window_id', 'Window'
);

my $buttons = $button_window->add(
    'mybuttons', 'Buttonbox',
    -buttons   => [
        {
          -label => '< Button 1 >',
          -value => 1,
          -shortcut => 1 
        }, {
          -label => '< Button 2 >',
          -value => 2,
          -shortcut => 2 
        }
    ]
);


$cui->set_binding(sub {$menu->focus()}, "\cX");
$cui->set_binding( \&exit_dialog , "\cQ");

$buttons->focus();
$cui->mainloop();

my $value = $buttons->get();
printf "$value\n";
