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


def test_validate_core_template_for_virtualbox(host):
    packer_validate(host, "Windows2012R2CoreVirtualbox.json")


def test_validate_core_template_for_azure_arm(host):
    packer_validate(host, "Windows2012R2CoreAzureARM.json", {
        'client_id': 'sample_value',
        'client_secret': 'sample_value',
        'subscription_id': 'sample_value'
    })


def test_validate_core_template_for_amazon_ebs(host):
    packer_validate(host, "Windows2012R2CoreAmazonEBS.json")
