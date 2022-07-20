FROM python:3.9

RUN git clone https://github.com/tncowart/python

ADD python /

ENV PYTHONPATH "${PYTHONPATH}:/python"

RUN pip3 install --trusted-host pypi.org pandas

ENTRYPOINT ["python"]  
