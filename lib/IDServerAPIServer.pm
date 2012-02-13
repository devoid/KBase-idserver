package IDServerAPIServer;

use Data::Dumper;
use Moose;
use KBRpcContext;

extends 'RPC::Any::Server::JSONRPC::PSGI';

has 'instance_dispatch' => (is => 'ro', isa => 'HashRef');
has 'user_auth' => (is => 'ro', isa => 'UserAuth');
has 'valid_methods' => (is => 'ro', isa => 'HashRef', lazy => 1,
			builder => '_build_valid_methods');

sub _build_valid_methods
{
    my($self) = @_;
    my $methods = {
        'kbase_ids_to_external_ids' => 1,
        'external_ids_to_kbase_ids' => 1,
        'register_ids' => 1,
        'allocate_id_range' => 1,
        'register_allocated_ids' => 1,
    };
    return $methods;
}

sub call_method {
    my ($self, $data, $method_info) = @_;
    my ($module, $method) = @$method_info{qw(module method)};
    
    my $ctx = KBRpcContext->new(client_ip => $self->_plack_req->address);
    
    my $args = $data->{arguments};
    if (@$args == 1 && ref($args->[0]) eq 'HASH')
    {
	my $actual_args = $args->[0]->{args};
	my $token = $args->[0]->{auth_token};
	$data->{arguments} = $actual_args;
	
	
        # Module IDServerAPI does not require authentication.
	
    }
    
    my $new_isa = $self->get_package_isa($module);
    no strict 'refs';
    local @{"${module}::ISA"} = @$new_isa;
    my @result = $module->$method($ctx, @{ $data->{arguments} });
    return \@result;
}


sub get_method
{
    my ($self, $data) = @_;
    
    my $full_name = $data->{method};
    
    $full_name =~ /^(\S+)\.([^\.]+)$/;
    my ($package, $method) = ($1, $2);
    
    if (!$package || !$method) {
	$self->exception('NoSuchMethod',
			 "'$full_name' is not a valid method. It must"
			 . " contain a package name, followed by a period,"
			 . " followed by a method name.");
    }

    if (!$self->valid_methods->{$method})
    {
	$self->exception('NoSuchMethod',
			 "'$method' is not a valid method in module IDServerAPI.");
    }
	
    my $inst = $self->instance_dispatch->{$package};
    my $module;
    if ($inst)
    {
	$module = $inst;
    }
    else
    {
	$module = $self->get_module($package);
	if (!$module) {
	    $self->exception('NoSuchMethod',
			     "There is no method package named '$package'.");
	}
	
	Class::MOP::load_class($module);
    }
    
    if (!$module->can($method)) {
	$self->exception('NoSuchMethod',
			 "There is no method named '$method' in the"
			 . " '$package' package.");
    }
    
    return { module => $module, method => $method };
}

1;
