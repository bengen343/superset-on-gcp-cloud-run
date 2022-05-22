# FROM apache/superset:71e3fa1bf350045da9a1c1e89443549c204a3516
FROM amancevice/superset:1.3.2

COPY superset_config.py /etc/superset/superset_config.py

# Switching to root to install the required packages
# USER root

# install postgres and bigquery driver
# RUN pip install psycopg2-binary pandas-gbq pybigquery

# Switching back to using the `superset` user
# USER superset
