package MatrixRealWWW;
use base 'CGI::Application';
use Math::MatrixReal;
use CGI::Carp qw/cluck fatalsToBrowser/;
use CGI::Untaint;
use warnings;

my %DIR =	( tmpl => q{/export/domains/leto.net/perl5lib/MatrixRealWWW/tmpl},
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
        $self->start_mode('choose');
        $self->mode_param('rm');
        $self->run_modes( map { $_ => 'show_'.$_ } qw( choose analyze solve )); }

sub header_and_footer {
	my $s = shift;
	my $h = slurp ($DIR{tmpl} ."/header.tmpl");
	my $f = slurp ($DIR{tmpl} ."/footer.tmpl");

	return $h . $s . $f;
}

sub show_choose { 
	my $file = slurp ($DIR{tmpl} ."/choose.tmpl");
        $file = header_and_footer($file);
	$file =~ s/%%TITLE%%/Choose A Matrix to Investigate with Math::MatrixReal/;
	return $file;
}
sub show_analyze {
	my $self = shift;
	my $q = $self->query();
	my ($output,$filename);
	my $file = slurp ($DIR{tmpl} . "/analyze.tmpl");
	my %args;  
	if( valid_params($q) ) {
		%args = untaint_params($q);
	} else {
		$output=error_page($q, "You have entered some invalid characters, please try again.");
		return $output;
	}

	if( $DEBUG ){
		while ( my ($k,$v) = each %args ){ $output.= "$k => $v\n"; }
		$output = as_comment($output);
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
	open(FD, "<", $f) or cluck $!;
	while(<FD>){ $output .= $_ };
	return $output;
}
sub as_comment{ "<!--\n" . (shift) . "--!>\n"; }
