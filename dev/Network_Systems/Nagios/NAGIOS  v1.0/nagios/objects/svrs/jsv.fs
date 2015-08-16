###############################################################################
# SVRS/JSV.CFG
# Last Modified:	2011-07-29
# Author:		Michael Spence
###############################################################################

# ausfs
define host{
        use             windows-host
        host_name       jsv-fs
        alias           JSV File Server
        address         10.35.1.1
        parents         jsv_core_hp2510_48p_1
        hostgroups      windows-servers,svr_file,svr_dhcp
        }

