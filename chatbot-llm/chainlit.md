# Red Hat RAG Demo ChatBot

This ChatBot uses Retrieval-Augmented Generation (RAG) to add knowledge about Red Hat's OpenShift AI and it's predessor Red Hat OpenShift Data Science (RH ODS) product.
Feel free to chat with it and learn about the product and see a RAG system working in parallel with an LLM which has no knowledge of its own about either product.

## Notes

- If your laptop is tight on resources, especially memory or older models, the LLM may run quite slowly
- If you wish to dive deeper and see what is 

## Useful Links and Resources 🔗

- **Red Hat OpenShift AI** [Landing Page](https://www.redhat.com/en/technologies/cloud-computing/openshift/openshift-ai) 
- **GitHub Repo**, [Codebase](https://github.com/tonykay) for this simple demo 

## Software Stack

- Chainlit, the UI you see in front of you
- LangChain, a popular Python (and JavaScript) AI Application framework
- Nomic, high performance Open Source Embeddings Library
- ChromaDB, a Vector Database used for the RAG **embeddings** and retrieval
- Podman, Container Engine from Red Hat, though Docker can also be used
- mistral-7B, a popular Open Source LLM (Large Langugae Model)
- Ollama, an LLM runtime allowing LLMs to be run locally on Linux, MacOS, and Windows machines


## Welcome screen

To modify the welcome screen, edit the `chainlit.md` file at the root of your project. If you do not want a welcome screen, just leave this file empty.
