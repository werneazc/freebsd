#!/bin/sh

#
# Copyright (c) 2010 Peter Holm <pho@FreeBSD.org>
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.
#
# $FreeBSD$
#

# SUJ suspfs deadlock seen

[ `id -u ` -ne 0 ] && echo "Must be root!" && exit 1

. ../default.cfg

mount | grep $mntpoint | grep -q /dev/md && umount -f $mntpoint
mdconfig -l | grep -q md$mdstart &&  mdconfig -d -u $mdstart
mdconfig -a -t swap -s 1g -u $mdstart
bsdlabel -w md$mdstart auto
newfs -j md${mdstart}$part > /dev/null
mount /dev/md${mdstart}$part $mntpoint
chmod 777 $mntpoint

export RUNDIR=$mntpoint/stressX
export runRUNTIME=20m
su $testuser -c "cd ..; ./run.sh rw.cfg"

while mount | grep $mntpoint | grep -q /dev/md; do
	umount $mntpoint || sleep 1
done
checkfs /dev/md${mdstart}$part
mdconfig -d -u $mdstart
