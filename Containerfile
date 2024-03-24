FROM registry.access.redhat.com/ubi9/python-311:latest

ENV HOME=/home/user
ENV PATH=/home/user/.local/bin:$PATH
ENV HF_HOME=/app/hugging_face
# TRANSFORMERS_CACHE=/app/embedding_models

EXPOSE 7001
EXPOSE 7002
EXPOSE 7003

# RUN useradd -m -u 1000 user

# COPY entrypoint.sh /usr/local/bin/
# RUN  chmod +x /usr/local/bin/entrypoint.sh

# TODO: Move to milvus
USER root
RUN dnf remove sqlite3 -y && \
  wget https://www.sqlite.org/2023/sqlite-autoconf-3410200.tar.gz && \
  tar -xvzf sqlite-autoconf-3410200.tar.gz && \
  cd sqlite-autoconf-3410200 && \
  ./configure && \
  make && \
  make install && \
  mv /usr/local/bin/sqlite3 /usr/bin/sqlite3 && \
  cd .. && \
  rm -rf sqlite-autoconf-3410200.tar.gz sqlite-autoconf-3410200
#  rm -rf /var/cache/dnf

USER 1001
WORKDIR /app
COPY --chown=1001 . .
RUN --mount=type=cache,target=/root/.cache \
  pip install --no-cache-dir -r requirements.txt && \
  python preload-embedding-model.py

# RUN chown -R user:user /home/user/app \
#   && chmod +x /usr/local/bin/entrypoint.sh
# # COPY . .
# # USER root
# # COPY ./requirements.txt /app/requirements.txt
# USER user

ENTRYPOINT ["/app/entrypoint.sh"]
