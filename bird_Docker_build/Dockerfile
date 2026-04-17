FROM python:3.9 AS bird-build

WORKDIR /

RUN wget https://github.com/stan-dev/cmdstan/releases/download/v2.35.0/cmdstan-2.35.0.tar.gz
RUN tar -zxpf cmdstan-2.35.0.tar.gz

RUN mv cmdstan-2.35.0 cmdstan
WORKDIR /cmdstan
RUN make build

COPY BIRD.stan .
RUN make BIRD

FROM python:3.9

# Install required system dependencies
RUN apt-get update && apt-get upgrade -y && apt-get install --no-install-recommends -y \
   libtbb12 \
   && rm -rf /var/lib/apt/lists/*

WORKDIR /
RUN git clone https://github.com/tncowart/python
ENV PYTHONPATH="/python"

WORKDIR /bird
RUN pip3 install pandas
COPY --from=bird-build /cmdstan/BIRD .
COPY bird.py .

ENTRYPOINT ["python", "bird.py", "BIRD"]
