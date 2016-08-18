#!/bin/sh

NOUVEAU_GIT_URL=https://github.com/skeggsb/nouveau.git
NOUVEAU_BASE_COMMIT=1d134769cc027a866ababdd652e126cbc5b8f7a2

function abort {
	echo "exiting"
	git am --abort 2>/dev/null
	git checkout master 2>/dev/null
	git branch -D _tmp
	git checkout ready 2>/dev/null
}

function die {
	echo "failure occured"
	exit
}

trap abort EXIT

[ ! -d "nouveau" ] && git clone $NOUVEAU_GIT_URL nouveau

function git {
	$(which git) -C nouveau $@ >/dev/null
}

echo "updating repository"
git fetch origin || die

git checkout $NOUVEAU_BASE_COMMIT -b _tmp || die
git branch -D ready 2>/dev/null

for series in $(cat patch_list); do
	for patch in $(find $series/ -type f | sort); do
		echo "adding patch: $patch"
		git am "../$patch" || die
	done
done

git checkout -b ready

echo "!!! nouveau patching done. Compile inside nouveau/drm"
