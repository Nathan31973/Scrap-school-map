#using scripts\codescripts\struct;

#using scripts\shared\callbacks_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\shared\weapons\_bouncingbetty;

#insert scripts\shared\shared.gsh;

#using scripts\zm\_util;

#namespace bouncingbetty;

REGISTER_SYSTEM( "bouncingbetty", &__init__, undefined )

function __init__( localClientNum )
{
	bouncingbetty::init_shared();
}