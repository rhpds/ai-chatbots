# LLM Configuration

MODEL = "mistral"
OLLAMA_BASE_URL = "http://localhost:11434"
# OLLAMA_BASE_URL = "http://host.containers.local:11434"

# Streamlit Headers

STREAMLIT_PAGE_TITLE = "Ragnarok: Chat with **your** Data"
# STREAMLIT_BOT_TITLE = "RAG Chat Bot :female-teacher:"
STREAMLIT_BOT_TITLE = "Chat Bot :female-teacher:"
STREAMLIT_SIDEBAR_TITLE = "Add additional sources for RAG (PDFs)"

USER_PROMPT = "Your questions?"
# TODO: Download and store in repo
USER_AVATAR = "https://cloudassembler.com/images/avatar.png"
BOT_AVATAR = "https://upload.wikimedia.org/wikipedia/commons/thumb/d/d8/Red_Hat_logo.svg/2560px-Red_Hat_logo.svg.png"

# RAG Setup and Vector Store (Chroma)

# PDF_FOLDER_PATH = "./rag-inputs"
# COLLECTION_NAME = "rh-ai-rag-demo"


RAG_CHUNK_OVERLAP = 10
RAG_CHUNK_SIZE = 1000
RAG_COLLECTION_NAME = "rh-ai-rag-demo"
RAG_EMBEDDING_MODEL = "nomic-embed-text-v1.5"
RAG_INPUTS = "./rag-inputs"
RAG_PERSIST_DIR = "./rag-persist"
