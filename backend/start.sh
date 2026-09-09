#!/bin/bash
# Render startup script: seed database then start the API server

python -m app.db.seed
uvicorn app.main:app --host 0.0.0.0 --port $PORT
