FROM philipandrewweedewang/dockerflaskbase:latest

WORKDIR /usr/local/bin
COPY API .

CMD python3 run_api.py