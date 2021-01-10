import argparse
import datetime
import subprocess

from universal_build import build_utils
from universal_build.helpers import build_docker

REMOTE_IMAGE_PREFIX = "mltooling/"
FLAG_FLAVOR = "flavor"
IMAGE_NAME = "ml-workspace"

parser = argparse.ArgumentParser(add_help=False)
parser.add_argument(
    "--" + FLAG_FLAVOR,
    help="Flavor (spark) used for docker container",
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
    args[FLAG_FLAVOR] = "spark"
    build_utils.build(".", args)
    build_utils.exit_process(0)

# unknown flavor -> try to build from subdirectory
if flavor not in ["spark"]:
    # assume that flavor has its own directory with build.py
    build_utils.build(flavor + "-flavor", args)
    build_utils.exit_process(0)

docker_image_name = IMAGE_NAME + "-" + flavor

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

base_image = "ml-workspace-r:" + VERSION
if args.get(build_utils.FLAG_RELEASE):
    base_image = docker_image_prefix + base_image

base_image_build_arg = " --build-arg ARG_WORKSPACE_BASE_IMAGE=" + base_image
vcs_ref_build_arg = " --build-arg ARG_VCS_REF=" + str(git_rev)
build_date_build_arg = " --build-arg ARG_BUILD_DATE=" + str(build_date)
flavor_build_arg = " --build-arg ARG_WORKSPACE_FLAVOR=" + str(flavor)
version_build_arg = " --build-arg ARG_WORKSPACE_VERSION=" + VERSION

if args.get(build_utils.FLAG_MAKE):
    build_args = f"{base_image_build_arg} {version_build_arg} {flavor_build_arg} {vcs_ref_build_arg} {build_date_build_arg}"

    build_docker.build_docker_image(
        docker_image_name, version=VERSION, build_args=build_args, exit_on_error=True
    )

if args.get(build_utils.FLAG_TEST):
    import docker

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

if args.get(build_utils.FLAG_RELEASE):
    build_docker.release_docker_image(
        docker_image_name, VERSION, docker_image_prefix, exit_on_error=True
    )
