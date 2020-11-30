import argparse
import datetime
import subprocess

import docker
from universal_build import build_utils
from universal_build.helpers import build_docker

parser = argparse.ArgumentParser(add_help=False)
parser.add_argument(
    "--flavor",
    help="flavor (full, light, minimal) used for docker container",
    default="gpu",
)

REMOTE_IMAGE_PREFIX = "mltooling/"
FLAG_FLAVOR = "flavor"
COMPONENT_NAME = "ml-workspace"

args = build_utils.parse_arguments(argument_parser=parser)

VERSION = str(args.get(build_utils.FLAG_VERSION))
docker_image_prefix = args.get(build_docker.FLAG_DOCKER_IMAGE_PREFIX)

if not docker_image_prefix:
    docker_image_prefix = REMOTE_IMAGE_PREFIX

if not args[FLAG_FLAVOR]:
    args[FLAG_FLAVOR] = "gpu"

args[FLAG_FLAVOR] = str(args[FLAG_FLAVOR]).lower()

if args[FLAG_FLAVOR] == "all":
    args[FLAG_FLAVOR] = "gpu"
    build_utils.build(".", args)
    build_utils.exit_process(0)

# unknown flavor -> try to build from subdirectory
if args[FLAG_FLAVOR] not in ["gpu"]:
    # assume that flavor has its own directory with build.py
    build_utils.build(args[FLAG_FLAVOR] + "-flavor", args)
    build_utils.exit_process(0)

docker_image_name = COMPONENT_NAME + "-" + args[FLAG_FLAVOR]

# docker build
git_rev = "unknown"
try:
    git_rev = (
        subprocess.check_output(["git", "rev-parse", "--short", "HEAD"])
        .decode("ascii")
        .strip()
    )
except Exception:
    pass

build_date = datetime.datetime.utcnow().isoformat("T") + "Z"
try:
    build_date = (
        subprocess.check_output(["date", "-u", "+%Y-%m-%dT%H:%M:%SZ"])
        .decode("ascii")
        .strip()
    )
except Exception:
    pass

vcs_ref_build_arg = " --build-arg ARG_VCS_REF=" + str(git_rev)
build_date_build_arg = " --build-arg ARG_BUILD_DATE=" + str(build_date)
flavor_build_arg = " --build-arg ARG_WORKSPACE_FLAVOR=" + str(args[FLAG_FLAVOR])
version_build_arg = " --build-arg ARG_WORKSPACE_VERSION=" + VERSION

if args[build_utils.FLAG_MAKE]:
    build_args = (
        version_build_arg
        + " "
        + flavor_build_arg
        + " "
        + vcs_ref_build_arg
        + " "
        + build_date_build_arg
    )

    completed_process = build_docker.build_docker_image(
        docker_image_name, version=VERSION, build_args=build_args
    )
    if completed_process.returncode > 0:
        build_utils.exit_process(1)

if args[build_utils.FLAG_TEST]:
    workspace_name = f"workspace-test-{args[build_utils.FLAG_FLAVOR]}"
    workspace_port = "8080"
    client = docker.from_env()
    container = client.containers.run(
        f"{docker_image_name}:{VERSION}",
        name=workspace_name,
        environment={
            "WORKSPACE_NAME": workspace_name,
            "WORKSPACE_ACCESS_PORT": workspace_port,
        },
        detach=True,
    )

    container.reload()
    container_ip = container.attrs["NetworkSettings"]["Networks"]["bridge"]["IPAddress"]

    completed_process = build_utils.run(
        f"docker exec -it --env WORKSPACE_IP={container_ip} {workspace_name} pytest '/resources/tests'",
        exit_on_error=False,
    )

    container.remove(force=True)
    if completed_process.returncode > 0:
        build_utils.exit_process(1)

if args[build_utils.FLAG_RELEASE]:
    build_docker.release_docker_image(
        docker_image_name,
        VERSION,
        docker_image_prefix,
    )
