FROM debian:stretch-slim

RUN apt-get update && apt-get install -y curl tar

WORKDIR /home
ENV JULIA_PKGDIR /home/julia/share/julia/site/
# download, unpack nightly julia binary
RUN curl https://julialangnightlies-s3.julialang.org/bin/linux/x64/julia-latest-linux64.tar.gz > julia.tar.gz && \
    mkdir julia && \
    tar xzf julia.tar.gz -C julia && \
    mv julia/$(cd julia; echo *)/* julia/ && \
    rm julia.tar.gz  && \
    rm -rf julia/share/doc && \
    rm -rf julia/share/julia/test && \
    rm julia/lib/julia/sys-debug.so && \
    rm julia/lib/libjulia-debug.so.0.7.0 && \
    find . -type f -name '*.cov' -delete && \
    find . -type f -name '*.mem' -delete

RUN julia/bin/julia -e 'using Pkg; Pkg.init(); Pkg.clone("MbedTLS"); Pkg.build("MbedTLS"); Pkg.clone("HTTP"); Pkg.clone("AMQPClient"); Pkg.clone("JSON2"); Pkg.clone("Missings"); Pkg.clone("FlatBuffers"); Pkg.clone("DataStreams"); Pkg.clone("MySQL"); Pkg.build("MySQL")'
COPY MbedTLS/deps.jl julia/share/julia/site/v0.7/MbedTLS/deps/deps.jl
COPY MySQL/deps.jl julia/share/julia/site/v0.7/MySQL/deps/deps.jl
COPY DecFP/deps.jl julia/share/julia/site/v0.7/DecFP/deps/deps.jl
RUN julia/bin/julia -e 'using HTTP; using Missings; using AMQPClient; using JSON2; using FlatBuffers; using MySQL'

RUN rm julia/LICENSE.md && rm julia/bin/julia-debug && \
    rm -rf julia/etc && rm -rf julia/include && \
    rm -rf julia/share/appdata && rm -rf julia/share/applications && \
    rm -rf julia/share/icons && rm -rf julia/share/man

CMD /bin/bash
