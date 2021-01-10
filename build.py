import argparse
import datetime
import subprocess

import docker
from universal_build import build_utils
from universal_build.helpers import build_docker

REMOTE_IMAGE_PREFIX = "mltooling/"
COMPONENT_NAME = "ml-workspace"
FLAG_FLAVOR = "flavor"

parser = argparse.ArgumentParser(add_help=False)
parser.add_argument(
    "--" + FLAG_FLAVOR,
    help="Flavor (full, light, minimal, r, spark, gpu) used for docker container",
    default="all",
)

args = build_utils.parse_arguments(argument_parser=parser)

VERSION = str(args.get(build_utils.FLAG_VERSION))
docker_image_prefix = args.get(build_docker.FLAG_DOCKER_IMAGE_PREFIX)

if not docker_image_prefix:
    docker_image_prefix = REMOTE_IMAGE_PREFIX

if not args.get(FLAG_FLAVOR):
    args[FLAG_FLAVOR] = "all"

flavor = str(args[FLAG_FLAVOR]).lower().strip()

if flavor == "all":
    args[FLAG_FLAVOR] = "minimal"
    build_utils.build(".", args)

    args[FLAG_FLAVOR] = "light"
    build_utils.build(".", args)

    args[FLAG_FLAVOR] = "full"
    build_utils.build(".", args)

    args[FLAG_FLAVOR] = "r"
    build_utils.build("r-flavor", args)

    args[FLAG_FLAVOR] = "spark"
    build_utils.build("spark-flavor", args)

    args[FLAG_FLAVOR] = "gpu"
    build_utils.build("gpu-flavor", args)

    args[FLAG_FLAVOR] = "gpu-r"
    build_utils.build("r-flavor", args)

    build_utils.exit_process(0)

# unknown flavor -> try to build from subdirectory
if flavor not in ["full", "minimal", "light"]:
    # assume that flavor has its own directory with build.py
    build_utils.build(flavor + "-flavor", args)
    build_utils.exit_process(0)

docker_image_name = COMPONENT_NAME
# Build full image without suffix if the flavor is not minimal or light
if flavor in ["minimal", "light"]:
    docker_image_name += "-" + flavor

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
flavor_build_arg = " --build-arg ARG_WORKSPACE_FLAVOR=" + str(flavor)
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
    workspace_name = f"workspace-test-{flavor}"
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
        f"docker exec --env WORKSPACE_IP={container_ip} {workspace_name} pytest '/resources/tests'",
        exit_on_error=False,
    )

    container.remove(force=True)
    if completed_process.returncode > 0:
        build_utils.exit_process(1)


if args[build_utils.FLAG_RELEASE]:
    # Bump all versions in some filess
    previous_version = build_utils.get_latest_version()
    if previous_version:
        build_utils.replace_in_files(
            previous_version,
            VERSION,
            file_paths=["./README.md", "./deployment/google-cloud-run/Dockerfile"],
            regex=False,
            exit_on_error=True,
        )

    build_docker.release_docker_image(
        docker_image_name,
        VERSION,
        docker_image_prefix,
    )
