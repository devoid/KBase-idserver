use Bio::KBase::IDServer::Impl;

use Bio::KBase::IDServer::Service;



my @dispatch;

{
    my $obj = Bio::KBase::IDServer::Impl->new;
    push(@dispatch, 'IDServerAPI' => $obj);
}


my $server = Bio::KBase::IDServer::Service->new(instance_dispatch => { @dispatch },
				allow_get => 0,
			       );

my $handler = sub { $server->handle_input(@_) };

$handler;
