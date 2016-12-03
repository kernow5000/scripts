#!/usr/bin/perl -w

# a simple ripped off script to change the wallpaper every <cron period you set>
# just specify an EXISTING image directory below, and specify your bgtool or something..meh
# and add the script to a cron job, 

# needs the full path for fbsetbg as its run by root

$imageDir = "/home/kernow/Pictures/wallpapers/";

# maybe one day I might use xset, so its more .. 'portable'
$bgTool = "/usr/X11R6/bin/fbsetbg";

# find all the jpgs in that dir
opendir(DIR, $imageDir) or die "Invalid directory specified.";
@files = grep(/\.jpg$/,readdir(DIR));
closedir(DIR);

# select a random value from @files, and print it to show its value
my $randomImage = $files[rand @files];

# set it using the fbsetbg program
$selected = $imageDir . $randomImage;
system "$bgTool $selected";

# end of perl script
# kernow 11/6/05
