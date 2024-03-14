from pathlib import Path

# from langchain_openai import ChatOpenAI #, OpenAIEmbeddings
from langchain.prompts import ChatPromptTemplate
from langchain.schema import StrOutputParser
from langchain_community.document_loaders import (
    PyMuPDFLoader,
)
from langchain.text_splitter import RecursiveCharacterTextSplitter
from langchain.vectorstores.chroma import Chroma
from langchain.indexes import SQLRecordManager, index
from langchain.schema.runnable import RunnablePassthrough, RunnableConfig
from langchain.callbacks.base import BaseCallbackHandler
# from langchain_community.llms.ollama import Ollama

from langchain.embeddings import GPT4AllEmbeddings
from langchain_community.embeddings import HuggingFaceEmbeddings
from langchain_community.chat_models import ChatOllama
import chainlit as cl
import config as cfg
import os

chunk_size = 1024
chunk_overlap = 50

# embeddings_model = OpenAIEmbeddings()
# embeddings_model = NomicEmbeddings(model="nomic-embed-text-v1.5")
# TODO: Clean up old embedding code - leave for now 2024-03-01

embeddings_model = GPT4AllEmbeddings()
# embeddings_model = HuggingFaceEmbeddings(model_name="all-MiniLM-L6-v2")
# GPT4AllEmbeddings()
# sentence_transformers

PDF_STORAGE_PATH = "./rag-inputs"


def process_pdfs(pdf_storage_path: str):
    pdf_directory = Path(pdf_storage_path)
    docs = []  # type: List[Document]
    text_splitter = RecursiveCharacterTextSplitter(chunk_size=1000, chunk_overlap=100)

    for pdf_path in pdf_directory.glob("*.pdf"):
        loader = PyMuPDFLoader(str(pdf_path))
        documents = loader.load()
        docs += text_splitter.split_documents(documents)

    doc_search = Chroma.from_documents(docs, embeddings_model)
    namespace = "chromadb/my_documents"

    #    file_path = os.path.abspath(os.getcwd()) + "\database.db"

    file_path = os.path.abspath(os.getcwd()) + "/rag-persist/record_manager_cache.sql"

    print(f"File path is {file_path}")

    record_manager = SQLRecordManager(
        # namespace, db_url="sqlite:///rag-persist/record_manager_cache.sql"
        namespace,
        db_url="sqlite:///" + file_path,
    )
    record_manager.create_schema()

    index_result = index(
        docs,
        record_manager,
        doc_search,
        cleanup="incremental",
        source_id_key="source",
    )

    print(f"Indexing stats: {index_result}")

    return doc_search


doc_search = process_pdfs(PDF_STORAGE_PATH)
# model = ChatOpenAI(model_name="gpt-4", streaming=True)
# TODO: Move globals to config.py (and capitilize)
OLLAMA_BASE_URL = os.getenv("OLLAMA_BASE_URL", cfg.OLLAMA_BASE_URL)
OLLAMA_MODEL = "mistral"

model = ChatOllama(
    model=OLLAMA_MODEL,
    base_url=OLLAMA_BASE_URL,
)

#    streaming=True,
#    TODO: Does ChatOllama support streaming?
# base_url="http://localhost:11434",


@cl.on_chat_start
async def on_chat_start():
    # template = """Answer the question based only on the following context:
    template = """Answer the question giving priority to the following context if it is relevant.
    If what follows does not answer the question silently ignore the following context and answer using your own knowledge:

    {context}

    Question: {question}
    """
    prompt = ChatPromptTemplate.from_template(template)

    def format_docs(docs):
        return "\n\n".join([d.page_content for d in docs])

    retriever = doc_search.as_retriever()
    output_parser = StrOutputParser()

    chain = (
        {"context": retriever | format_docs, "question": RunnablePassthrough()}
        | prompt
        | model
        | output_parser
    )
    # Red Hat RAG Demo ChatBot
    await cl.Message(content="See Readme tab for tips").send()
    cl.user_session.set("runnable", chain)


@cl.on_message
async def on_message(message: cl.Message):
    runnable = cl.user_session.get("runnable")  # type: Runnable
    msg = cl.Message(content="")

    class PostMessageHandler(BaseCallbackHandler):
        """
        Callback handler for handling the retriever and LLM processes.
        Used to post the sources of the retrieved documents as a Chainlit element.
        """

        def __init__(self, msg: cl.Message):
            BaseCallbackHandler.__init__(self)
            self.msg = msg
            self.sources = set()  # To store unique pairs

        def on_retriever_end(self, documents, *, run_id, parent_run_id, **kwargs):
            for d in documents:
                source_page_pair = (d.metadata["source"], d.metadata["page"])
                self.sources.add(source_page_pair)  # Add unique pairs to the set

        def on_llm_end(self, response, *, run_id, parent_run_id, **kwargs):
            if len(self.sources):
                sources_text = "\n".join(
                    [f"{source}#page={page}" for source, page in self.sources]
                )
                self.msg.elements.append(
                    cl.Text(name="Sources", content=sources_text, display="inline")
                )

    async with cl.Step(type="run", name="QA Assistant"):
        async for chunk in runnable.astream(
            message.content,
            config=RunnableConfig(
                callbacks=[cl.LangchainCallbackHandler(), PostMessageHandler(msg)]
            ),
        ):
            await msg.stream_token(chunk)

    await msg.send()
