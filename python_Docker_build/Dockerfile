FROM python:3.9

RUN wget --no-check-certificate https://github.com/bmajoros/BIRD/blob/master/bird.py

ENV PYTHONPATH "${PYTHONPATH}:/opt/anaconda3/bin/python3"

RUN pip3 install --trusted-host pypi.org pandas

ENTRYPOINT ["python", "bird.py"]  
