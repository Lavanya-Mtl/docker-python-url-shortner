# Use slim image to keep size down
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Install dependencies first (layer caching — rebuilds faster)
COPY app/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy app code
COPY app/ .

# Non-root user for security (good practice, looks great in interviews)
RUN adduser --disabled-password --gecos "" appuser
USER appuser

# Expose port
EXPOSE 8000

# Run the app
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]