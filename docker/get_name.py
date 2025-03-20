#!/usr/bin/env python3

from docker import DockerClient
import os

hostname = os.environ['HOSTNAME']

client = DockerClient(base_url='unix://var/run/docker.sock')
containers = client.containers.list()

for container in containers:
    id = container.id[:12]
    if id == hostname:
        print(container.name)
        quit()

print(hostname)
