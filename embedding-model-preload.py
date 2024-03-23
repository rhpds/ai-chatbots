"""
Preload the embeddings model 

Simplifies the Containerbuild process by "baking in" the model
at build time.

- Faster Container starts
- Works completely offline

"""
from sentence_transformers import SentenceTransformer

model = SentenceTransformer("all-MiniLM-L6-v2")
