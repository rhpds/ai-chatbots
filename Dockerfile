FROM python:3.11
RUN useradd -m -u 1000 user
USER user
ENV HOME=/home/user \
  PATH=/home/user/.local/bin:$PATH
WORKDIR $HOME/app
COPY --chown=user . $HOME/app
COPY ./requirements.txt ~/app/requirements.txt
RUN pip install -r requirements.txt
COPY . .
USER root
RUN chown -R user:user /home/user/app
USER user
CMD ["chainlit", "run", "chatbot-rag.py", "--port", "7860"]
