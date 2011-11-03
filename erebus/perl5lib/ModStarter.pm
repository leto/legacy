package ModStarter;
use base 'CGI::Application';
use Module::Starter; 
use File::Temp qw/tempfile tempdir/;
use CGI::Carp qw/fatalsToBrowser/;
use CGI::Untaint;
use Archive::Zip qw/:ERROR_CODES :CONSTANTS/;
use warnings;

eval { use Data::Dumper } if $DEBUG;
my %DIR =	( tmpl => q{/export/domains/leto.net/perl5lib/ModStarter/tmpl},
		  htdocs => q{/export/domains/leto.net/htdocs},
		  lib => q{/export/domains/leto.net/perl5lib},
		);
my $DEBUG = 0;
my $BASEDIR = "/export/domains/leto.net/htdocs";
my $VERSION = 0.01;
my $ROW = '<tr><td>%%FIELD%%</td><td>%%INPUT%%</td></tr>';
my @TAGS = qw( distro names builder license author email );
my %RE = (
		distro  => qr/^([A-z0-9]*)$/,
		names   => qr/^([A-z0-9:_ -]{3,255})$/,
		builder => qr/^([A-z0-9:_-]{3,40})$/,
		license => qr/^([A-z0-9_ -]{3,40})$/,
		author  => qr/^([A-z_ -]{3,40})$/,
		email  => qr/^(.+\@.+)$/,	# loose definition
	);

sub setup {
        my $self = shift;
        $self->start_mode('mode1');
        $self->mode_param('rm');
        $self->run_modes(
                'mode1' => 'show_page1',
                'mode2' => 'show_page2',
        );
}
sub header_and_footer {
	my $s = shift;
	my $h = slurp ($DIR{tmpl} ."/header.tmpl");
	my $f = slurp ($DIR{tmpl} ."/footer.tmpl");

	return $h . $s . $f;
}
sub show_page1 { 
	my $file = slurp ($DIR{tmpl} ."/page1.tmpl");
        $file = header_and_footer($file);
	$file =~ s/%%TITLE%%/Start a New Perl Module/;
	return $file;
}
sub show_page2 {
	my $self = shift;
	my $q = $self->query();
	my ($output,$filename);
	my $file = slurp ($DIR{tmpl} . "/page2.tmpl");
	my @modules = split / /, $q->param('module_names');
  	my $dir = tempdir(DIR=>"tmp");
	my %args;  
	if( valid_params($q) ) {
		%args = untaint_params($q);
	} else {
		$output=error_page($q, "You have entered some invalid characters, please try again.");
		return $output;
	}

	$args{modules}  = \@modules ;
	$args{force}	= 1;
	$args{distro} ||= $modules[0];
	$filename 	= $args{distro};
 	$filename 	=~ s/::/-/g ;
	$args{dir}	="$dir/$filename";

	if( $DEBUG ){
		while ( my ($k,$v) = each %args ){
			$output.= "$k => $v\n";
		}
		$output = as_comment($output);
	}
	eval { Module::Starter->create_distro(%args); };
	if ($@){
		$output .= error_page($q, "Seems like Module::Starter had an unexpected error, oops!<br>");
	} else  {
		make_zip($dir, $filename );
		$output .= "Download your new Perl module, <a href=$dir/$filename/$filename.zip>$filename.zip</a> and have fun!";
		$output .= "<br>You can browse the <a href=$dir/$filename/>source</a> if you like.<br>";
	}
	$file=header_and_footer( $file );
	$file=~s/%%CONTENT%%/$output/;
	$file=~s/%%TITLE%%/View and Download $modules[0]/;
	return $file;
}
sub valid_params {
	my $q = shift;
	my $ok = 1;
	
	map { $q->param('module_'.$_) !~ /$RE{$_}/ && ($ok = 0) } @TAGS;
	return $ok;
}
sub untaint_params {
	my $q = shift;
	my %args; 
	map { $args{$_} = $q->param('module_'.$_) } @TAGS;
	for(@TAGS){
		if( $args{$_} =~ /$RE{$_}/ ){
			$args{$_} = $1;
		} else { $args{$_} = -42; }
	}
	return %args;
}
sub make_zip {
	my ($d,$f) = @_;
	my $zip = Archive::Zip->new();
	$zip->addTree( "$d/$f", $f);
	unless ( $zip->writeToFileNamed("$d/$f/$f.zip") == AZ_OK ) {
	    carp "error making zip file $d/$f/$f.zip : $!";
	}
}
sub error_page{
	my ($q,$msg) = @_;
	my $head = slurp ($DIR{tmpl} . "/header.tmpl");
	my $errpage = slurp ($DIR{tmpl} . "/error_page.tmpl");
	my $errfoot = slurp ($DIR{tmpl} . "/footer_error.tmpl");
	my $output= $head . $errpage . $errfoot;
	$msg ||= "Seems like you put in some weird data.<br>";
	$output =~ s/%%TITLE%%/Error!/;
	$output =~ s/%%ERROR%%/$msg/;
	return $output;
}
sub slurp {
	my $f = shift;
	my $output;
	open(FD, "<", $f) or die $!;
	while(<FD>){ $output .= $_ };
	return $output;
}
sub as_comment{ "<!--\n" . (shift) . "--!>\n"; }
