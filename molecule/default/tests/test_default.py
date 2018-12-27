import os

import testinfra.utils.ansible_runner

testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(
    os.environ['MOLECULE_INVENTORY_FILE']).get_hosts('all')


def packer_validate(host, template, args={}):
    path = "/tmp/packer/"
    param_list = ['--var "{}={}"'.format(k, v) for k, v in args.items()]
    params = ' '.join(param_list)
    cmd = host.run("packer validate {} {}{}".format(params, path, template))
    assert cmd.rc == 0, "Validation of {} failed. STDOUT: {}\nSTDERR: {}" \
        .format(template, cmd.stdout, cmd.stderr)


def test_validate_custom_template(host):
    packer_validate(host, "CustomBuild.json")


def test_validate_package(host):
    packer_validate(host, "PackageBuild.json")
