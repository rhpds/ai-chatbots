"""
    Query an existing Milvus vector store with LangChain
    * Connect
    * Query
    * Output
"""
from langchain_community.embeddings import GPT4AllEmbeddings
from langchain_community.vectorstores import Milvus

# Retreive a stored collection
collection_name = "collection_1"
embeddings = GPT4AllEmbeddings()

vector_db = Milvus(
    embeddings,
    collection_name=collection_name,
    connection_args={"host": "127.0.0.1", "port": "19530"},
)

query = "What did the president say about Ketanji Brown Jackson"
docs = vector_db.similarity_search(query)

print(f"{docs[0].page_content}")

#    collection_name="collection_1",
