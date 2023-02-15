# Use a base image with NixOs
FROM nixos/nix

SHELL ["/nix/var/nix/profiles/default/bin/bash", "-c"]

RUN nix-channel --update

RUN nix-env -f '<nixpkgs>' -iA python310Full python310Packages.pip zlib stdenv.cc.cc.lib

ENV APP_DIR=/app

RUN mkdir $APP_DIR
WORKDIR $APP_DIR

# Need to enable flakes 
#RUN mkdir -p ~/.config/nix && echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf

RUN git clone https://github.com/krasina15/nix-python.git -b simpleDocker .

ENV VIRTUAL_ENV=$APP_DIR/.venv

RUN python -m venv $VIRTUAL_ENV \
 && source $VIRTUAL_ENV/bin/activate \
 && pip install -r requirements.txt .

ENV NIX_LINK=/root/.nix-profile
ENV LD_LIBRARY_PATH="$NIX_LINK"/lib
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

CMD ["python", "build/lib/nix_python/serve.py"]
# CMD . /app/.venv/bin/activate && exec python /app/build/lib/nix_python/serve.py
