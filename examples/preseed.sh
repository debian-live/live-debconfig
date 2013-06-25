#!/bin/sh

_PRESEED_FILE="preseed.cfg"

cat > "${_PRESEED_FILE}" << EOF
# live-debconfig ($(cat ../VERSION))

live-debconfig live-debconfig/components multiselect 
EOF

for _COMPONENT in $(ls ../components/????-* | grep -v ".templates")
do
	_COMPONENT_NAME="$(basename ${_COMPONENT} | sed -e 's|^[0-9][0-9][0-9][0-9]-||')"

cat >> "${_PRESEED_FILE}" << EOF

# ${_COMPONENT_NAME}
EOF

	for _DEBCONF in $(grep db_get ${_COMPONENT} | sed -e 's|.*db_get ||' -e 's|&&.*$||')
	do
		if ! grep -qs "live-debconfig ${_DEBCONF}" "${_PRESEED_FILE}"
		then
			if echo "${_DEBCONF}" | grep -qs '\{'
			then
				_COMMENT="#"
				_TYPE=""
			else
				_COMMENT=""
				_TYPE=" $(grep -A1 -m1 "^Template: ${_DEBCONF}" ../components/*-${_COMPONENT_NAME}.templates | awk '/^Type: / { print $2 }')"
			fi


			echo "${_COMMENT}live-debconfig ${_DEBCONF}${_TYPE} " >> "${_PRESEED_FILE}"
		fi
	done
done
