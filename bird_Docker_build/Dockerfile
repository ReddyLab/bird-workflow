FROM python:3.9

WORKDIR /

RUN wget https://github.com/stan-dev/cmdstan/releases/download/v2.30.0/cmdstan-2.30.0.tar.gz
RUN tar -zxpf cmdstan-2.30.0.tar.gz

RUN mv cmdstan-2.30.0 cmdstan
WORKDIR /cmdstan
RUN make build

RUN wget --no-check-certificate https://github.com/bmajoros/BIRD/blob/master/bird.py

COPY BIRD.stan .
RUN make BIRD
RUN mv BIRD BIRD-1.1

ENTRYPOINT ["bird.py", "BIRD-1.1"]  
