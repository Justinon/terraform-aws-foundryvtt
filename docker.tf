locals {
    docker_compose_foundry_document = {
        version = "3.8"
        services = {
            foundry_server = {
                image = var.foundryvtt_docker_image
                container_name = "foundry-server"
            }
        }
    }
}