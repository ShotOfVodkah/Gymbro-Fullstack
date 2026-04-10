FROM python:3.11-slim

# System deps for torch (C++ libs) and git (for HF hub)
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy requirements first for layer caching
COPY services/ai_service/requirements.txt ./requirements.txt

# Install PyTorch CPU wheel from the dedicated index, then the rest
RUN pip install --no-cache-dir \
    torch==2.6.0 \
    --index-url https://download.pytorch.org/whl/cpu \
 && pip install --no-cache-dir -r requirements.txt \
    --extra-index-url https://download.pytorch.org/whl/cpu

# Copy service source and data files
COPY services/ai_service/app ./app
COPY services/ai_service/exercises.json ./exercises.json
COPY services/ai_service/schema.json ./schema.json
COPY services/ai_service/workout_lora_model ./workout_lora_model

ENV PYTHONUNBUFFERED=1
ENV HF_HOME=/root/.cache/huggingface

EXPOSE 8083

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8083"]
