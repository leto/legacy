package ModStarter;
use base 'CGI::Application';
use Module::Starter; 
use File::Temp qw/tempfile tempdir /;
use CGI::Carp qw/fatalsToBrowser/;
use Archive::Zip qw( :ERROR_CODES :CONSTANTS );
eval { use Data::Dumper } if $DEBUG;

my $DEBUG = 0;
my $BASEDIR = "/export/domains/leto.net/htdocs";
my $VERSION = 0.01;
my $ROW = '<tr><td>%%FIELD%%</td><td>%%INPUT%%</td></tr>';
my @TAGS = qw( distro modules dir builder license author email );

sub setup {
        my $self = shift;
        $self->start_mode('mode1');
        $self->mode_param('rm');
        $self->run_modes(
                'mode1' => 'show_page1',
                'mode2' => 'show_page2',
        );
}
sub show_page1 { 
        my $self = shift; 
        my $q = $self->query(); 
        my $output = ''; 
        $output .= $q->start_html(-title => 'Start a New CPAN Module'); 
	$output .= "<center><h2>Start a New CPAN Module</h2>";
	$output .= q{<table border=0 width=100%><tr><td> <a href=http://cpan.org><img border=0 src=/pics/camel.gif></a></td><td> };
	$output .= q{ <p>
		<form method="post" action="/modstarter.cgi" enctype="multipart/form-data">
		<table border=0>
		<tr><th>Module Name(s)</th><td><input type="text" name="module_names" value="My::New::Module" size="30" /></td></tr>
		<tr><th>Distribution</th><td><input type="text" name="module_distro"  size="30" /></td></tr>
		<tr><th>Builder</th><td>
		<select name="module_builder">};
	$output .=  "<option value=\"$_\">$_</option>" for (qw{Module::Build ExtUtils::MakeMaker Module::Install});

	$starter_form = q{</select></td></tr> <tr><th>License</th><td><input type="text" name="module_license" value="perl"  size="30" /></td></tr>
		<tr><th>Author</th><td><input type="text" name="module_author"  size="30" /></td></tr>
		<tr><th>Email</th><td><input type="text" name="module_email"  size="30" /></td></tr>
		</table> <input type="hidden" name="rm" value="mode2"  /><input value="Create Module" type="submit" name=".submit" /></form>
		</td></tr></table>};
	$output .= $starter_form . q{<br><b>Hints</b>:<br> Leave Distribution blank if you are only creating one module. <br>
			Separate multiple module names by spaces.<br> };
			

	$output  .= $q->end_html();
        return $output;
}
sub show_page2 {
	my $self = shift;
	my $q = $self->query();
	my %args = clean_args($q); 
	my $output;

	if( $args{author} ){
		$output .= "Creating your new module...<br>";
	} else {
		$output = "You must have a <b>name</b>, yes?";
		return $output;
	}
	my @modules = split / /, $q->param('module_names');
  	my $dir = tempdir(DIR=>"tmp");
	$args{modules}= \@modules ;
	$args{force}=1;
	$args{distro} ||=  $modules[0];
	my $filename = $args{distro};

 	$filename =~ s/::/-/g ;
		
	$args{dir}="$dir/$filename";

	if ( $args{author} && length $args{author} < 50 && $filename  && length $filename < 80 ){
		eval { Module::Starter->create_distro(%args); };
		if ($@) { $output = "Play nice!<!-- foo -->";  } 
		else  {
			make_zip($dir, $filename );
			$output .= "Download your new Perl module, <a href=$dir/$filename/$filename.zip>$filename.zip</a> and have fun!";
			$output .= "<br>You can browse the <a href=$dir/$filename/>source</a> if you like.<br>";
		}
	} else {
		$output .= "Module name not valid. It must contain only letters, numbers and colons. And not be TOO long.<br>";
	}
	return $output;
}
sub clean_args {
	my $q = shift;
	my %args; my @tags = qw(distro builder license author email);
	map { $args{$_} = $q->param('module_'.$_) } @tags;
	$args{distro}  =~ s/[^A-z0-9_-]+//g;
	$args{builder} =~ s/[^A-z0-9:]+//g;
	$_ =~ s/[^A-z0-9:]*//g for @$args{modules};
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
