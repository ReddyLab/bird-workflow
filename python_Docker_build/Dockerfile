FROM python:3.9

WORKDIR /

RUN git clone https://github.com/tncowart/python

ENV PYTHONPATH "${PYTHONPATH}:/python"

RUN pip3 install pandas

ENTRYPOINT ["python"]  
