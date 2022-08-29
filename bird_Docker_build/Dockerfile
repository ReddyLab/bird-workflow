FROM python:3.9 as BIRD

WORKDIR /

RUN wget https://github.com/stan-dev/cmdstan/releases/download/v2.30.0/cmdstan-2.30.0.tar.gz
RUN tar -zxpf cmdstan-2.30.0.tar.gz

RUN mv cmdstan-2.30.0 cmdstan
WORKDIR /cmdstan
RUN make build

COPY BIRD.stan .
RUN make BIRD

FROM python:3.9

WORKDIR /
RUN git clone https://github.com/tncowart/python
ENV PYTHONPATH "${PYTHONPATH}:/python"

WORKDIR /bird
RUN pip3 install pandas
COPY --from=BIRD /cmdstan/BIRD .
COPY bird.py .

ENTRYPOINT ["python", "bird.py", "BIRD"]
