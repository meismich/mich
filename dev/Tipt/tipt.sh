#!/bin/ksh
# File:		tipt.sh
# Date:		2011-10-29
# Author:	Michael Spence

# Usage
# tipt.sh <username> <password>
# eg:
#	tipt.sh admpag@apeagers.com.au tamwood


# Users
# Get the number of pages of users
n=$( bin/get_user_pages.sh $1 $2 )

#  Get Users
bin/get_users.sh $1 $2 $n

# Process Users
bin/proc_users.sh

# Get User information
bin/get_user_info.sh $1 $2

bin/proc_user_info.sh


# Hunt Groups
# Get Hunt groups
bin/get_HGs.sh $1 $2

# Proc Hunt Groups
bin/proc_HGs.sh

# Get Hunt Group Info
bin/get_HG_info.sh $1 $2


# Auto Attendants
# Get Auto attendants
bin/get_AAs.sh $1 $2

# Process Auto attendants
bin/proc_AAs.sh

# Get Auto attendant info
bin/get_AA_info.sh $1 $2
