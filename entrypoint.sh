#!/usr/bin/env bash

if [ "$#" -eq 0 ]; then
	echo Starting Chatbots deamons
	(
		cd /app/chatbot-llm
		chainlit run chatbot-llm.py --port 7001 | tee /tmp/chatbot-rag.log &
	)
	(
		cd /app/chatbot-rag
		chainlit run chatbot-rag.py --port 7002 | tee /tmp/chatbot-rag.log &
	)
	(
		cd /app/www
		python -m http.server 7003 | tee /tmp/httpd.log
	)
else
	exec "$@"
fi
