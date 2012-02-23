use IDServerAPIImpl;

use IDServerAPIServer;



my @dispatch;

{
    my $obj = IDServerAPIImpl->new;
    push(@dispatch, 'IDServerAPI' => $obj);
}


my $server = IDServerAPIServer->new(instance_dispatch => { @dispatch },
				allow_get => 0,
			       );

my $handler = sub { $server->handle_input(@_) };

$handler;
