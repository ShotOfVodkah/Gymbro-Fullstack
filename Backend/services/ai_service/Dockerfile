# Build with context = this directory (see Backend/deploy/docker-compose.yml: ai_service).
FROM python:3.11-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    libopenblas-dev \
    pkg-config \
    git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY requirements.txt ./requirements.txt

RUN pip install --no-cache-dir llama-cpp-python==0.3.8 \
 && pip install --no-cache-dir -r requirements.txt

COPY app ./app
COPY exercises.json ./exercises.json
COPY schema.json ./schema.json

COPY workout_q4km.gguf ./workout_q4km.gguf

ENV PYTHONUNBUFFERED=1

EXPOSE 8085

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8085"]
