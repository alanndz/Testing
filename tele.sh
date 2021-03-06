#!/usr/bin/env bash
# Main Setup
TELE=~/telegram/telegram
TELE_TOKEN=799058967:AAHdBKLP8cjxLXUCxeBiWmEOoY8kZHvbiQo
TELE_ID=671339354

# Main Telegram
#function sendInfo() {
# $TELE -t $TELE_TOKEN -c $TELE_ID "${1}"
#}

function sendInfo() {
	$TELE -t ${TELE_TOKEN} -c ${TELE_ID} -H \
		"$(
			for POST in "${@}"; do
				echo "${POST}"
			done
		)"
}

function send() {
	curl -s "https://api.telegram.org/bot$TELE_TOKEN/sendMessage" \
		-d "parse_mode=HTML" \
		-d text="${1}" \
		-d chat_id="$TELE_ID" \
		-d "disable_web_page_preview=true"
}

function sendFile() {
	$TELE -t $TELE_TOKEN -c $TELE_ID -f $ZIP_DIR/aLN*.zip
}

#send "--aLN Kernel New Build--" \
		"Started at " \
		"Started on<code> $(hostname) </code>" \
		"Branch : " \
		"Commit : " \
		"Build Started!!!"

send "$(echo -e "<b>--aLN Kernel New Build--</b>\n*Started at *\nStarted on<code> $((hostname)) </code>\nBranch : \nCommit : \nBuild")"