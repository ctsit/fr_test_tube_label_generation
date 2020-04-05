#!/usr/bin/perl

use Getopt::Std;


# Usage/help message.
$usage = <<USAGE;
Usage: prlabels [options] [filename]
Print file folder labels on Avery 5160 sheets

  -r m : start at row m (range: 1..10; default: 1)
  -c n : start at column n (range 1..3; default: 1)
  -h   : print this message

If no filename is given, use STDIN. A label entry is a plain text
series of non-blank lines. Blank lines separate entries.

The first line of an entry is special. If it starts with a #, then it's
considered a header line. Everything in the header line up to the | is
printed flush left in bold and everything after the | is printed flush
right in bold. Subsequent lines are printed centered in normal weight.
If the first line of an entry doesn't start with #, it uses the header
of the previous entry.
USAGE

# Set up geometry constants for Avery 5160.
$topmargin = 0.60;
$poleft = 0.4;
$pomiddle = 3.20;
$poright = 5.95;
$lheight = 1;

# get starting point from command line if present
getopts('hr:c:', \%opt);
die $usage if ($opt{h});

$row = int($opt{r}) || 1;    # chop off any fractional parts and
$col = int($opt{c}) || 1;

# Bail out if position options are out of bounds
die $usage unless (($row >= 1 and $row <= 10) and
                   ($col >= 1 and $col <= 3));

# Set initial horizontal and vertical positions.
if ($col == 1) {
  $po = $poleft;
} elsif ($col == 2) {
  $po = $pomiddle;
} else {
  $po = $poright;
}
$sp = ($topmargin + ($row - 1)*$lheight);

# Pipe output through groff and ps2pdf.
open OUT, "| groff | ps2pdf -";
# open OUT, "> labels.rf";    # for debugging
select OUT;

# Set up document.
print <<SETUP;
.ps 11
.vs 15
.ll 2.20i
.ta 2.20iR

SETUP

# The troff code for formatting a single entry, with placeholders for
# positioning on the page. The magic numbers embedded in the formatting
# commands make the layout look nice.
$label = <<ENTRY;
.sp |%.2fi
.po %.2fi
.ft HB
%s
.ft H
.ce 3
%s
.ce 0
ENTRY

# Slurp all the input into an array of entries.
$/ = "";
@entries = <>;

$bp = 0;                  # we don't want to start with a page break

foreach $body (@entries) {
  # Parse and transform the header and body.
  if ($body =~ /^#/) {    # it's a header line
    ($header, $body) = split(/\n/, $body, 2);
    $header = substr($header, 1);
    $header =~ s/\|/\t/;
  }
  $body =~ s/\s+$//;

  # Break page if we ran off the end.
  if ($bp) {
    print "\n.bp\n";      # issue the page break command
    $bp = 0;              # reset flag
  }

  # Print the label.
  printf $label, $sp, $po, $header, $body;

  # Now we set up for the next entry.
  if ($col == 1){       # last entry was in the left column
    $col = 2;             # so the next will be in
    $po = $pomiddle;      # the middle column
  } elsif ($col == 2) { # last entry was in the middle column
    $col = 3;             # so the next will be in
    $po = $poright;       # the right column
  } else {              # last was in the right column
    $col = 1;             # so the next will be in
    $po = $poleft;        # the left column
    $row++;               # of the next row
    if ($row > 10) {      # we're at the end of the page
      $bp = 1;            # page break flag
      $row = 1;           # new page starts at top row
    }
    $sp = ($topmargin + ($row - 1)*$lheight);
  }
}
