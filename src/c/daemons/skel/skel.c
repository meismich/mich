/*
 * FILE:	skel.c
 * DATE:	2009-12-31
 * AUTHOR:	Michael Spence
 *
 * PURPOSE:
 * Provides a skeleton template for creating unix daemons.
 */
#include <stdio.h>
#include <fcntl.h>
#include <signal.h>
#include <unistd.h>

/* CONSTANTS
 */

/* PROTOTYPES
 */

/* MAIN
 */

int main (int argv, char *argc) {
	
	int i, lf;

	if (fork())
		return -90;
	setsid();
	for (i=getdtablesize(); i>=0; --i)
		close(i);
	i=open("/dev/null", 0_RDWR); dup(i); dup(i);
	umask(027);
	chdir(WD_DAEMON);
	if ((lf=open(LOCK_FILE


	return 0;
	}

/* AUX FUNCTIONS
 */


