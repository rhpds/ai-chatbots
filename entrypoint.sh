#!/usr/bin/env bash

APP_HOME=$(pwd)

if [ "$#" -eq 0 ]; then
	echo Starting Chatbots deamons and web server
	(
		cd ${APP_HOME}/chatbot-llm
		chainlit run chatbot-llm.py --port 7001 | tee -a /tmp/ai-chatbots.log &
	)
	(
		cd ${APP_HOME}/chatbot-rag
		chainlit run chatbot-rag.py --port 7002 | tee -a /tmp/ai-chatbots.log &
	)
	(
		cd ${APP_HOME}/www
		python -m http.server 7003 | tee -a /tmp/ai-chatbots.log &
	)
else
	exec "$@"
fi
