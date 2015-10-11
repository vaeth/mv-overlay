#! /bin/sh
echo `/bin/date --utc +'%F %X'` "${1}" d om "${BYTES_RCVD}" "${BYTES_SENT}" \
	>>'ACCOUNTING_LOG'
