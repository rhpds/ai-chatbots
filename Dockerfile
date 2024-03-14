FROM python:3.11

ENV HOME=/home/user \
  PATH=/home/user/.local/bin:$PATH

EXPOSE 7001
EXPOSE 7002
EXPOSE 7003

RUN useradd -m -u 1000 user
COPY entrypoint.sh /usr/local/bin/
USER user
WORKDIR $HOME/app
COPY --chown=user . $HOME/app
COPY ./requirements.txt ~/app/requirements.txt
RUN --mount=type=cache,target=/root/.cache \
  pip install -r requirements.txt
COPY . .
USER root
RUN chown -R user:user /home/user/app \
  && chmod +x /usr/local/bin/entrypoint.sh
USER user

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
