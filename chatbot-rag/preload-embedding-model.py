# from langchain_community.embeddings import GPT4AllEmbeddings
# import os
# embedding_model = os.getenv("EMBEDDING_MODEL", "MiniLM-L6-v2")
# embeddings = GPT4AllEmbeddings(model=embedding_model)

from langchain.embeddings.sentence_transformer import SentenceTransformerEmbeddings

embeddings = SentenceTransformerEmbeddings()
