use IDServerAPIImpl;
use IDServerAPIServer;



my $impl_obj = IDServerAPIImpl->new;

my $server = IDServerAPIServer->new(instance_dispatch => { 'IDServerAPI' => $impl_obj },

				allow_get => 0,
			       );

my $handler = sub { $server->handle_input(@_) };

$handler;
