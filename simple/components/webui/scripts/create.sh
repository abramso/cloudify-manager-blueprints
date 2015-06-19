#!/bin/bash -e

. $(ctx download-resource "components/utils")


export NODEJS_SOURCE_URL=$(ctx node properties nodejs_tar_source_url)  # (e.g. "http://nodejs.org/dist/v0.10.35/node-v0.10.35-linux-x64.tar.gz")
export WEBUI_SOURCE_URL=$(ctx node properties webui_tar_source_url)  # (e.g. "https://dl.dropboxusercontent.com/u/407576/cosmo-ui-3.2.0-m4.tgz")
export GRAFANA_SOURCE_URL=$(ctx node properties grafana_tar_source_url)  # (e.g. "https://dl.dropboxusercontent.com/u/407576/grafana-1.9.0.tgz")

export NODEJS_HOME="/opt/nodejs"
export WEBUI_HOME="/opt/cloudify-ui"
export WEBUI_LOG_PATH="/var/log/cloudify/webui"
export GRAFANA_HOME="${WEBUI_HOME}/grafana"


ctx logger info "Installing Cloudify's WebUI..."

copy_notice "webui"
webui_notice=$(ctx download-resource "components/webui/LICENSE")
sudo mv ${webui_notice} "/opt/LICENSE"

create_dir ${NODEJS_HOME}
create_dir ${WEBUI_HOME}
create_dir ${WEBUI_HOME}/backend
create_dir ${WEBUI_LOG_PATH}
create_dir ${GRAFANA_HOME}

ctx logger info "Installing NodeJS..."
nodejs=$(download_file ${NODEJS_SOURCE_URL})
sudo tar -xzvf ${nodejs} -C ${NODEJS_HOME} --strip-components=1 >/dev/null

ctx logger info "Installing Cloudify's WebUI..."
webui=$(download_file ${WEBUI_SOURCE_URL})
sudo tar -xzvf ${webui} -C ${WEBUI_HOME} --strip-components=1 >/dev/null
ctx logger info "Applying Workaround for missing dependencies..."
sudo ${NODEJS_HOME}/bin/npm install --prefix ${WEBUI_HOME} request tar

ctx logger info "Installing Grafana..."
grafana=$(download_file ${GRAFANA_SOURCE_URL})
sudo tar -xzvf ${grafana} -C ${GRAFANA_HOME} --strip-components=1 >/dev/null

ctx logger info "Deploying WebUI Configuration..."
webui_conf=$(ctx download-resource "components/webui/config/gsPresets.json")
sudo mv ${webui_conf} "${WEBUI_HOME}/backend/gsPresets.json"
ctx logger info "Deploying Grafana Configuration..."
grafana_conf=$(ctx download-resource "components/webui/config/config.js")
sudo mv ${grafana_conf} "${GRAFANA_HOME}/"
