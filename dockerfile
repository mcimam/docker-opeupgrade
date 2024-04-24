FROM ubuntu:jammy
ARG DEBIAN_FRONTEND=noninteractive

RUN set -x; \
    apt update \
    && apt install -y --no-install-recommends\
        ca-certificates \
        curl \
        git \
        node-less \
        python3 \
        python3-pip \
        python3-setuptools \
        python3-renderpm \
        python3-dev \
        build-essential \
        libldap2-dev\
        libpq-dev\
        libsasl2-dev\
        wget\
        wkhtmltopdf\
        gnupg\
    && rm -rf /var/lib/apt/lists/

# Install psql client
RUN set -x; \
    wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
    && echo "deb http://apt.postgresql.org/pub/repos/apt/ jammy-pgdg main" | tee  /etc/apt/sources.list.d/pgdg.list \
    && apt update \
    && apt install -y postgresql-client

# Open upgrade
RUN pip install git+https://github.com/OCA/openupgradelib.git@master#egg=openupgradelib

# Clone specific odoo branch
WORKDIR /odoo/15.0
RUN git clone -b 15.0 --single-branch https://github.com/odoo/odoo.git /odoo/15.0
RUN pip install -r requirements.txt

WORKDIR /odoo/16.0
RUN git clone -b 16.0 --single-branch https://github.com/odoo/odoo.git /odoo/16.0
RUN pip install -r requirements.txt

# Clone Open upgrade
WORKDIR /OpenUpgrade/15.0
RUN git clone -b 15.0 --single-branch https://github.com/OCA/OpenUpgrade.git /OpenUpgrade/15.0

WORKDIR /OpenUpgrade/16.0
RUN git clone -b 16.0 --single-branch https://github.com/OCA/OpenUpgrade.git /OpenUpgrade/16.0


# ADD DEFAULT THINGS
WORKDIR /
