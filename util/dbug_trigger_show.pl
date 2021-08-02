#!/usr/local/bin/perl -w

=pod

=head1 NAME

dbug_trigger_show.pl - Show the state of data using DBUG output of DBUG_TRIGGER triggers.

=head1 SYNOPSIS

perl dbug_trigger_show.pl [ B<-h> ] B<file(s)>

=head1 DESCRIPTION

This script show the database state after a DBUG_TRIGGER trigger has been
fired. All columns will be displayed with their actual data. Data columns will
be sorted alphabetically. Since dbug_trigger only shows changes, missing data
is retrieved from previous triggers fired.

=head1 OPTIONS

=over 4

=item h

Display help.

=back

=head1 NOTES

=head1 EXAMPLES

The script dbug_trigger.sql has been run to produce a dbug trigger on table
WS2. When a session has been run with dbug enabled and the output file has
been converted using dbugrpt the following file is input for dbug_trigger_show.pl:

  >INSERT ROW TRIGGER WS2_DBUG ON WS2
  |   info: from remote: FALSE
  |   key: ROW_ID: "1"
  |   data: DELETED: "N"
  |   data: WIND1_A: "W28 :"
  |   data: WIND2_A: "W10 :"
  |   data: WINDINFO1_A: "243-275 25404/04-03"
  |   data: WINDINFO2_A: "235-265 24104/04-04"
  |   data: HH1_B: "hh(ft):..... 26"
  |   data: HH2_B: "08  hh(ft):....."
  |   data: E: "P1500m"
  |   data: F: "P1500m"
  |   data: G: "P1500m"
  |   data: H: "P1500m"
  |   data: ARROW1_B: "--->"
  |   data: ARROW2_B: "--->"
  |   data: M_E: "P1500m"
  |   data: M_F: "P1500m"
  |   data: M_G: "P1500m"
  |   data: M_H: "P1500m"
  |   data: MITTEL_B: "MITTEL"
  |   data: WIND1_B: "W26 :"
  |   data: WIND2_B: "W08 :"
  |   data: WINDINFO1_B: "237-251 24705/06-05"
  |   data: WINDINFO2_B: "234-256 24605/06-04"
  |   data: QFE: "998.2=29.48"
  |   data: QNH: "1015.2=29.98"
  |   data: TEMP: "  1.9"
  |   data: DEWP: "  0.3"
  |   data: CAT_RWY_A: "28"
  |   data: CAT_A: "1"
  |   data: CAT_ATTR_A: "N"
  |   data: CAT_INFO_A: "LGT TLF INFO 3REH STB 3RWE 3RCL 3TDZ ZUE!"
  |   data: CAT_RWY_B: "26"
  |   data: CAT_B: "1"
  |   data: CAT_ATTR_B: "N"
  |   data: CAT_INFO_B: "LGT INFO STB 3TXC"
  <INSERT ROW TRIGGER WS2_DBUG ON WS2;  elapsed time:   0.150 (incl.),   0.150 (excl.)
  >UPDATE ROW TRIGGER WS2_DBUG ON WS2
  |   info: from remote: FALSE
  |   key: ROW_ID: "1"
  |   data: DAT: "" -> "2004-12-02"
  |   data: TIM: "" -> "23:00:00"
  |   data: SR: "" -> "0656"
  |   data: SS: "" -> "1505"
  |   data: RUNWAY_A: "" -> "28"
  |   data: HH1_A: "" -> "hh(ft):..... 28"
  |   data: HH2_A: "" -> "10  hh(ft):....."
  |   data: A: "" -> "P1500m"
  |   data: B: "" -> "P1500m"
  |   data: C: "" -> "P1500m"
  |   data: ARROW1_A: "" -> "--->"
  |   data: ARROW2_A: "" -> "--->"
  |   data: M_A: "" -> "P1500m"
  |   data: M_B: "" -> "P1500m"
  |   data: M_C: "" -> "P1500m"
  |   data: MITTEL_A: "" -> "MITTEL"
  |   data: WINDINFO2_A: "235-265 24104/04-04" -> "235-265 24004/04-04"
  |   data: RUNWAY_B: "" -> "26"
  <UPDATE ROW TRIGGER WS2_DBUG ON WS2;  elapsed time:   0.120 (incl.),   0.120 (excl.)

This will result in the following output:

  >INSERT ROW TRIGGER WS2_DBUG ON WS2
  |   info: from remote: FALSE
  |   key: ROW_ID: "1"
  |   data: ARROW1_B: "--->"
  |   data: ARROW2_B: "--->"
  |   data: CAT_A: "1"
  |   data: CAT_ATTR_A: "N"
  |   data: CAT_ATTR_B: "N"
  |   data: CAT_B: "1"
  |   data: CAT_INFO_A: "LGT TLF INFO 3REH STB 3RWE 3RCL 3TDZ ZUE!"
  |   data: CAT_INFO_B: "LGT INFO STB 3TXC"
  |   data: CAT_RWY_A: "28"
  |   data: CAT_RWY_B: "26"
  |   data: DELETED: "N"
  |   data: DEWP: "  0.3"
  |   data: E: "P1500m"
  |   data: F: "P1500m"
  |   data: G: "P1500m"
  |   data: H: "P1500m"
  |   data: HH1_B: "hh(ft):..... 26"
  |   data: HH2_B: "08  hh(ft):....."
  |   data: MITTEL_B: "MITTEL"
  |   data: M_E: "P1500m"
  |   data: M_F: "P1500m"
  |   data: M_G: "P1500m"
  |   data: M_H: "P1500m"
  |   data: QFE: "998.2=29.48"
  |   data: QNH: "1015.2=29.98"
  |   data: TEMP: "  1.9"
  |   data: WIND1_A: "W28 :"
  |   data: WIND1_B: "W26 :"
  |   data: WIND2_A: "W10 :"
  |   data: WIND2_B: "W08 :"
  |   data: WINDINFO1_A: "243-275 25404/04-03"
  |   data: WINDINFO1_B: "237-251 24705/06-05"
  |   data: WINDINFO2_A: "235-265 24104/04-04"
  |   data: WINDINFO2_B: "234-256 24605/06-04"
  <INSERT ROW TRIGGER WS2_DBUG ON WS2;  elapsed time:   0.150 (incl.),   0.150 (excl.)
  >UPDATE ROW TRIGGER WS2_DBUG ON WS2
  |   info: from remote: FALSE
  |   key: ROW_ID: "1"
  |   data: A: "P1500m"
  |   data: ARROW1_A: "--->"
  |   data: ARROW1_B: "--->"
  |   data: ARROW2_A: "--->"
  |   data: ARROW2_B: "--->"
  |   data: B: "P1500m"
  |   data: C: "P1500m"
  |   data: CAT_A: "1"
  |   data: CAT_ATTR_A: "N"
  |   data: CAT_ATTR_B: "N"
  |   data: CAT_B: "1"
  |   data: CAT_INFO_A: "LGT TLF INFO 3REH STB 3RWE 3RCL 3TDZ ZUE!"
  |   data: CAT_INFO_B: "LGT INFO STB 3TXC"
  |   data: CAT_RWY_A: "28"
  |   data: CAT_RWY_B: "26"
  |   data: DAT: "2004-12-02"
  |   data: DELETED: "N"
  |   data: DEWP: "  0.3"
  |   data: E: "P1500m"
  |   data: F: "P1500m"
  |   data: G: "P1500m"
  |   data: H: "P1500m"
  |   data: HH1_A: "hh(ft):..... 28"
  |   data: HH1_B: "hh(ft):..... 26"
  |   data: HH2_A: "10  hh(ft):....."
  |   data: HH2_B: "08  hh(ft):....."
  |   data: MITTEL_A: "MITTEL"
  |   data: MITTEL_B: "MITTEL"
  |   data: M_A: "P1500m"
  |   data: M_B: "P1500m"
  |   data: M_C: "P1500m"
  |   data: M_E: "P1500m"
  |   data: M_F: "P1500m"
  |   data: M_G: "P1500m"
  |   data: M_H: "P1500m"
  |   data: QFE: "998.2=29.48"
  |   data: QNH: "1015.2=29.98"
  |   data: RUNWAY_A: "28"
  |   data: RUNWAY_B: "26"
  |   data: SR: "0656"
  |   data: SS: "1505"
  |   data: TEMP: "  1.9"
  |   data: TIM: "23:00:00"
  |   data: WIND1_A: "W28 :"
  |   data: WIND1_B: "W26 :"
  |   data: WIND2_A: "W10 :"
  |   data: WIND2_B: "W08 :"
  |   data: WINDINFO1_A: "243-275 25404/04-03"
  |   data: WINDINFO1_B: "237-251 24705/06-05"
  |   data: WINDINFO2_A: "235-265 24004/04-04"
  |   data: WINDINFO2_A: "235-265 24104/04-04"
  |   data: WINDINFO2_B: "234-256 24605/06-04"
  <UPDATE ROW TRIGGER WS2_DBUG ON WS2;  elapsed time:   0.120 (incl.),   0.120 (excl.)

=head1 BUGS

=head1 SEE ALSO

=over 4

=item DBUG

See L<https://github.com/TransferWare/plsdbug>.

=item src/sql/dbug_trigger.pls

Create package DBUG_TRIGGER for logging changes to database.

=item ./dbug_trigger.sql

Generated triggers based on package DBUG_TRIGGER.

=back

=head1 AUTHOR

Gert-Jan Paulissen

=head1 HISTORY

13-dec-2004 G.J. Paulissen

Creation.

=cut

use English;
use strict;
use Getopt::Std;
use File::Basename;

&main;

sub main {
    my $table;
    my %data; # $data{$table}{$column} contains value of column $column for table $table

    # Windows FTYPE and ASSOC cause the command 'file2std  -h -c file'
    # to have ARGV[0] == '  -h -c file' and number of arguments 1.
    # Hence strip the spaces from $ARGV[0] and recreate @ARGV.
    if ( @ARGV == 1 && $ARGV[0] =~ s/^\s+//o ) {
        @ARGV = split( / /, $ARGV[0] );
    }
    

    &getopts("h");

    # need at least one argument
    &usage
        if ( defined($::opt_h) || $#ARGV == -1 );

    while (<>) {
        if (m/>(INSERT|UPDATE|DELETE) ROW TRIGGER \S+ ON (\S+)/o) {
            $table = $2;
            delete $data{$table} if ( $! eq 'DELETE' );
            print $_;
        } elsif (m/<(INSERT|UPDATE|DELETE) ROW TRIGGER \S+/o) {
            foreach my $column (sort keys %{$data{$table}}) {
                print $column, ": ", $data{$table}{$column}, "\n";
            }
            undef $table;
            print $_;
        } elsif (m/info: from remote: /o) {
            print $_;
        } elsif (m/\bkey: [^:]+: ".*"/o) {
            print $_;
        } elsif (m/^(.*\bdata: [^:]+): ".*" -> (".*")/o) {
            $data{$table}{$1} = $2;
        } elsif (m/^(.*\bdata: [^:]+): (".*")/o) {
            $data{$table}{$1} = $2;
        } else {
            print $_;
        }
    }

    # prohibit Perl message about a typo
    undef $::opt_h;
} # main


sub usage {
    my $program_name = &basename($PROGRAM_NAME);

    # Erase evidence of previous errors (if any), so exit status is simple.
    $! = 0;
    die <<EOF;

Usage: $program_name [OPTION]... [FILE]...

Show the state of data using DBUG output of DBUG_TRIGGER triggers.

OPTION:
    -h   This help.

EOF
} # usage

__END__

