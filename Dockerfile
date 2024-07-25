FROM nikolaik/python-nodejs:python3.12-nodejs22

LABEL version="13.14.1"
LABEL repository="https://github.com/gannonk08/firebase-action-python"
LABEL homepage="https://github.com/gannonk08/firebase-action-python"
LABEL maintainer="Kristjan Gannon <gannonk08@github.com>"

LABEL com.github.actions.name="GitHub Action for Firebase specificallly for python "
LABEL com.github.actions.description="Wraps the firebase-tools CLI to enable common commands."
LABEL com.github.actions.icon="package"
LABEL com.github.actions.color="blue"

RUN apt update && apt-get install --no-install-recommends -y jq default-jre && rm -rf /var/lib/apt/lists/*

RUN npm i -g npm@8.10.0 && npm cache clean --force
RUN npm i -g firebase-tools@13.14.1 && npm cache clean --force

COPY LICENSE README.md /
COPY "entrypoint.sh" "/entrypoint.sh"

ENTRYPOINT ["/entrypoint.sh"]
CMD ["--help"]
