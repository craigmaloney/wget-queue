#!/usr/bin/perl
# wget-queue.pl (Based off of wget-queue.sh bash script)
# Version 1.1
# Written by Craig Maloney
# (C) 2004 Craig Maloey
# Released under the GPL
# Reads from a todo list and downloads each of the files in turn.
# Maintains a list of URLS already downloaded to avoid extra effort

use Digest::MD5 qw(md5_hex);

# Initialize (Put this in a config file?)
$home_dir = $ENV{HOME};
$download_dir = "$home_dir/downloads/"; # Directory to download files
$user = $ENV{USER};
chdir "$download_dir";
$list_files = "$download_dir/todo.txt";
$completed_files = "$download_dir/done.txt";
$log = "$download_dir/wget.log";
$prog = "/usr/bin/wget";
$done = ();
# End of init. Shouldn't need to configure after this point

# Build completed files hash
if (-e $completed_files) {
	open DONE, $completed_files; 
	while (<DONE>) {
		chomp;
		$done{$_} =1;
	}
	close DONE;
}


if (-e $list_files) {
	open LIST, "$list_files" || die "Can't open list of files.\n";
} else {
	exit(1);
}
open DONE, ">>$completed_files" || warn "Can't write completed files\n";

while (<LIST>) {
	$line = $_;
	chomp $line;
	$digest = md5_hex($line);
	if (not($done{$digest})) { # Haven't seen this URL before
			print "Retreiving $line\n";
			`$prog -a $log -c "$line"`;
			if ($? != 0) {
				warn "Download failed. Please check the logs for more information\n";
			} else {
				print DONE "$digest\n";
				print "Download completed. Writing digest.\n";
			}
	} else {
		print "Already downloaded $line. Skipping.\n";
	}
}
close DONE;
close LIST;
