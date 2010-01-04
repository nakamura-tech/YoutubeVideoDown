use strict;
use warnings;
use Encode;

use WWW::Mechanize;
use JSON;

my $url = shift;
my $dir = "./";

if (not $url =~ m[(^http://youtube\.com/watch)|(^http://.*\.youtube\.com/watch)]) {
  die "Not youtube website\n";
}

print "URL: $url\n";

my $mech = WWW::Mechanize->new( agent=>'Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.0; Trident/4.0)', autocheck=>1 );
$mech->get($url);

my ($swfargs) = $mech->content =~ m|var swfArgs = (.+);|i;

if (not $swfargs) {
  ($swfargs) = $mech->content =~ m|'SWF_ARGS': (.+?),\n|i;
}
if (not $swfargs) {
  ($swfargs) = $mech->content =~ m|CFG_SWF_ARGS: (.+?),\n|i;
}

die "can't get swf args\n" if not $swfargs;

my $json = decode_json($swfargs);

my ($base) = $mech->uri =~ m|^(http://.+/)|;
my $video_url = "${base}get_video?video_id=$json->{video_id}&t=$json->{t}&fmt=18";

my ($title) = $mech->content =~ m|<\s*h1\s*>(.+)<\s*/h1\s*>|i;
$title = encode("utf8", decode("utf8", $title));
$title =~ s[\W][]gi;

my $file = "${dir}${title}.mp4";

die "Exists: $file \n" if (-e $file);

print "  title: $title \n";

$mech->get($video_url, ":content_file"=>$file);
