from langchain_community.chat_models import ChatOllama

from langchain.prompts import ChatPromptTemplate
from langchain.schema import StrOutputParser
from langchain.schema.runnable import Runnable
from langchain.schema.runnable.config import RunnableConfig

import chainlit as cl
import config as cfg
import os

# TODO: Move these to config?
OLLAMA_BASE_URL = os.getenv("OLLAMA_BASE_URL", cfg.OLLAMA_BASE_URL)
OLLAMA_MODEL = "mistral"


@cl.on_chat_start
async def on_chat_start():
    model = ChatOllama(
        model=OLLAMA_MODEL,
        base_url=OLLAMA_BASE_URL,
        streaming=True,
    )

    # TODO: Refacor to use ChatPromptTemplate.from_template in a prompt.py
    prompt = ChatPromptTemplate.from_messages(
        [
            (
                "system",
                "You're a very helpful Software Development and Technology Assistant.",
            ),
            ("human", "{question}"),
        ]
    )
    runnable = prompt | model | StrOutputParser()
    cl.user_session.set("runnable", runnable)


@cl.on_message
async def on_message(message: cl.Message):
    runnable = cl.user_session.get("runnable")  # type: Runnable

    msg = cl.Message(content="")

    async for chunk in runnable.astream(
        {"question": message.content},
        config=RunnableConfig(callbacks=[cl.LangchainCallbackHandler()]),
    ):
        await msg.stream_token(chunk)

    await msg.send()