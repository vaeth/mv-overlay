#! /bin/sh
[ -z "${PROVIDER}" ] && PROVIDER='Gentoo'
echo `/bin/date --utc +'%F %X'` "${1}" u om "\"${PROVIDER} ${1}\"" \
	>>'ACCOUNTING_LOG'
