#!/usr/bin/env bash

architecture="${architecture}"
artifacts_bucket="${foundry_artifacts_bucket}"
foundry_docker_image="${foundry_docker_image}"
foundry_gid="${foundry_gid}"
foundry_port="${foundry_port}"
foundry_uid="${foundry_uid}"
operating_system="${operating_system}"
region="${region}"
terraform_workspace="${terraform_workspace}"

###### FUNCTIONS ######

install_docker_compose() {
  local docker_compose_version="1.26.0"
  local docker_compose_url="https://github.com/docker/compose/releases/download/$${docker_compose_version}/docker-compose-$${operating_system}-$${architecture}"
  sudo curl --silent -L $${docker_compose_url} -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose
  sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
}

install_dependencies() {
  sudo yum --assumeyes --quiet install py-pip python-dev libffi-dev openssl-dev gcc libc-dev make docker
  sudo yum --assumeyes --quiet update
  install_docker_compose
}

# Attempt to download and unpack existing foundry data
get_foundry_data() {
  existing_data="$(aws s3api list-objects --bucket $${artifacts_bucket} --prefix data/$${terraform_workspace}/foundryvtt-data.tar.gz --query Contents[].Key --output text)"
  if [ ! "$${existing_data}" = "None" ]; then
    if aws s3 --region $${region} cp --only-show-errors --no-progress s3://$${artifacts_bucket}/$${existing_data} /data/; then
      data_tar=/data/$(basename "$${existing_data}")
      [ -f "$${data_tar}" ] && tar -xzvf "$${data_tar}" && rm -rf "$${data_tar}"|| echo "Error extracting foundry data, starting fresh..."
    else
      echo "Error downloading existing foundry data, starting fresh..."
    fi
  else
    echo "Could not locate existing foundry data in $${terraform_workspace} workspace, starting fresh..."
  fi
}

prep_docker() {
  sudo groupadd docker
  sudo usermod -aG docker ec2-user
  sudo service docker start
  sudo docker image pull $${foundry_docker_image}
}

start_server() {
  # Aqcuire foundry credentials
  foundry_namespace="/foundryvtt-terraform/$${terraform_workspace}"
  foundry_user="$(aws ssm --region $${region} get-parameter --name $${foundry_namespace}/username --with-decryption --query Parameter.Value --output text)"
  foundry_pass="$(aws ssm --region $${region} get-parameter --name $${foundry_namespace}/password --with-decryption --query Parameter.Value --output text)"
  foundry_admin_key="$(aws ssm --region $${region} get-parameter --name $${foundry_namespace}/admin_key --with-decryption --query Parameter.Value --output text)"
  
  # Start the foundry instance
  sudo docker run -d \
    --name foundry-server \
    --env FOUNDRY_ADMIN_KEY="$${foundry_admin_key}" \
    --env FOUNDRY_AWS_CONFIG=true \
    --env FOUNDRY_GID="$${foundry_gid}" \
    --env FOUNDRY_PASSWORD="$${foundry_pass}" \
    --env FOUNDRY_UID="$${foundry_uid}" \
    --env FOUNDRY_USERNAME="$${foundry_user}" \
    --publish $${foundry_port}:$${foundry_port}/tcp \
    --volume /data:/data \
    $${foundry_docker_image}
}

# Create foundry data backup cron
set_data_backup_job() {
  cron_cmd="tar -czvf /data/foundryvtt-data.tar.gz /data/Data && aws s3 cp --only-show-errors --no-progress /data/foundryvtt-data.tar.gz s3://$${artifacts_bucket}/data/$${terraform_workspace}/ && rm -rf /data/foundryvtt-data.tar.gz"
  echo -e "0 3 * * * $${cron_cmd} >/dev/null 2>&1" | sudo crontab -
}

###### BEGIN EXECUTION ######

install_dependencies
get_foundry_data
prep_docker
start_server
set_data_backup_job