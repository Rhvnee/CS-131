FROM python:3.10-bullseye

# Install Java 17 
RUN apt-get update && \
    apt-get install -y --no-install-recommends openjdk-17-jdk wget curl && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Set Java environment variables
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH=$JAVA_HOME/bin:$PATH

# Install PySpark and Jupyter
RUN pip install --no-cache-dir pyspark notebook pandas matplotlib

WORKDIR /work
EXPOSE 8888

CMD ["jupyter", "notebook", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--allow-root"]
