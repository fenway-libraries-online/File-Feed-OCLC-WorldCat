package File::Feed::OCLC::WorldCat;

# ABSTRACT: WorldCat MARC record files from OCLC

use base qw(File::Feed);
use vars qw($VERSION);

$VERSION = '0.01';

use constant ADD     => 'add';
use constant REPLACE => 'replace';
use constant DELETE  => 'delete';

sub _file_instance {
    my ($self, %arg) = @_;
    if ($arg{'from'} =~ m{^(?:.*/)?metacoll\.([^.]+)\.(new|updates|deletes)\.D(\d\d\d\d)(\d\d)(\d\d)\.T(\d\d)(\d\d)(\d\d)(?:\.(.+))?\.(\d)\.([a-z]+)$}) {
        # File name spec from http://www.oclc.org/content/dam/support/worldshare-metadata/retrieve_marc.pdf (retrieved 2014-06-25)
        $arg{'oclc-symbol'} ||= $1;
        $arg{'purpose'}     ||= $2 eq 'new' ? ADD : $2 eq 'updates' : REPLACE : DELETE;
        my ($Y, $m, $d, $H, $M, $S) = ($3, $4, $5, $6, $7, $8);
        $H = '00' if $H eq '24';  # Why oh why do they make this mistake??
        @arg{qw(date year month day hour minute second)} = ($Y.$m.$d.'T'.$H.$M.$S, $Y, $m, $d, $H, $M, $S);
        $arg{'collection'}  ||= $9 if defined $9;
        $arg{'digit'}       ||= $10;
        $arg{'mime-type'}   ||= $11 eq 'mrc' ? 'application/marc' : $11 eq 'xml' ? 'text/xml' : 'application/octet-stream';
        $arg{'time-zone'}   ||= 'American/New_York';
    }
    return $self->SUPER::_file_instance(%arg);
}

