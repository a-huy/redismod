FROM redisai/redisai:latest as redisai
FROM redisearch/redisearch:latest as redisearch
FROM redisgraph/redisgraph:latest as redisgraph
FROM redistimeseries/redistimeseries:latest as redistimeseries
FROM redisjson/redisjson:latest as redisjson
FROM redisbloom/redisbloom:latest as redisbloom
FROM redisgears/redisgears:latest

ENV LD_LIBRARY_PATH /usr/lib/redis/modules
ENV REDISGRAPH_DEPS libgomp1

WORKDIR /data
RUN set -ex; \
    apt-get update; \
    apt-get install -y --no-install-recommends ${REDISGRAPH_DEPS};

COPY --from=redisai ${LD_LIBRARY_PATH}/*.so* ${LD_LIBRARY_PATH}/
COPY --from=redisearch ${LD_LIBRARY_PATH}/redisearch.so ${LD_LIBRARY_PATH}/
COPY --from=redisgraph ${LD_LIBRARY_PATH}/redisgraph.so ${LD_LIBRARY_PATH}/
COPY --from=redistimeseries ${LD_LIBRARY_PATH}/*.so ${LD_LIBRARY_PATH}/
COPY --from=redisjson ${LD_LIBRARY_PATH}/*.so ${LD_LIBRARY_PATH}/
COPY --from=redisbloom ${LD_LIBRARY_PATH}/*.so ${LD_LIBRARY_PATH}/

# ENV PYTHONPATH /usr/lib/redis/modules/deps/cpython/Lib
ENTRYPOINT ["redis-server"]
CMD ["--loadmodule", "/usr/lib/redis/modules/redisai.so", \
    "--loadmodule", "/usr/lib/redis/modules/redisearch.so", \
    "--loadmodule", "/usr/lib/redis/modules/redisgraph.so", \
    "--loadmodule", "/usr/lib/redis/modules/redistimeseries.so", \
    "--loadmodule", "/usr/lib/redis/modules/rejson.so", \
    "--loadmodule", "/usr/lib/redis/modules/redisbloom.so", \
    "--loadmodule", "/opt/redislabs/lib/modules/redisgears.so", \
    "PythonHomeDir", "/opt/redislabs/lib/modules/python3"]
