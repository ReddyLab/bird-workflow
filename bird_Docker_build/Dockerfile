FROM python:3.9

WORKDIR /

RUN wget https://github.com/stan-dev/cmdstan/releases/download/v2.30.0/cmdstan-2.30.0.tar.gz
RUN tar -zxpf cmdstan-2.30.0.tar.gz

RUN mv cmdstan-2.30.0 cmdstan
WORKDIR /cmdstan
RUN make build

COPY BIRD.stan .
RUN make BIRD

COPY run_BIRD.sh run_BIRD.sh
CMD run_BIRD.sh 
