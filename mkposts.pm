use strict;

<>;
<>;
<>;

my ($date, $post, $title);

sub write_post {
    $date =~ s/^\s*(\S.*\S)\s*$/$1/;
    $post =~ s/^\s*(\S.*\S)\s*$/$1/;
    $title =~ s/^\s*(\S.*\S)\s*$/$1/;
    my ($d, $t) = split(' ', $date);
    my $filename = "${d}-${title}.md";
    $filename =~ s/\s+/-/g;
    open my $FH, ">$filename" or die "failed to open $filename";
    print $FH "${date}\n${title}\n${post}\n";
    close $FH;
    undef $date, $post, $title;
}

my $state = 0;
my $prev;
my $fields_left;
while (<>) {
    chomp;
    next if /^\s*$/;
    next if /^\+-----\+/;
    if ($state == 0 and /^\|/) {
        m/^\|\s*\d+\s*
           \|\s*\d+\s*
           \|[^|]+
           \|\s*(\d+-\d+-\d+\s*\d+:\d+:\d+)\s+
           \|\s*(.*)$
         /x or die "bad line '$_'";
        $date = $1;
        my $rest = $2;
        if ($rest =~ /^([^|]+)$/) {
            my $part = $1;
            $post = $part;
            $state = 1;
        } elsif ($rest =~ /^([^|]+)\s+\|\s*([^|]+)\s*\|/) {
            my $part = $1;
           $post .= $part;
            $title = $2;
            write_post();
            $state = 0;
        } else {
            die "unparsed: '$_'";
        }
    } elsif ($state == 1 and /^([^|]+)$/) {
        my $part = $1;
        $post .= $part;
        $state = 1;
    } elsif ($state == 1 and /^([^|]+)\s+\|\s*([^|]+)\s*\|(.*)$/) {
        my $part = $1;
        $post .= $part;
        $title = $2;
        write_post();
        my @extra_fields = split('\|', $3);
        $fields_left = 17 - scalar(@extra_fields);
        if ($fields_left == 0) {
            $state = 0;
        } elsif ($fields_left > 0) {
            $state = 2;
        } else {
            die "bad field setup with $fields_left fields left: $_";
        }
    } elsif ($state == 2 and /^\s*[^\| ]/) {
        my @extra_fields = split('\|', $_);
        my $fl = $fields_left - scalar(@extra_fields);
        if ($fl == 0) {
            $state = 0;
            $fields_left = $fl;
        } elsif ($fields_left > 0) {
            $state = 2;
            $fields_left = $fl;
        } else {
            die "bad field setup with $fields_left -> $fl fields left: $_";
        }
    } else {
        die "unparsed in outer: '$_' while state = $state and prev = '$prev' and fields_left=$fields_left";
    }
    $prev = $_;
}
