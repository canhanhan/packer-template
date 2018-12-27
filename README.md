packer-template
=========

Ansible role to generate Packer templates using YAML and Jinja2.

Due to limitations of JSON, Packer templates contain a lot of code duplication. Flexibility of YAML and Jinja2, helps to reduce the duplication.


Requirements
------------

No requirements for executing the module.

### Testing Requirements
Molecule and docker are required for testing. On Debian/Ubuntu based system you can install using:

```bash
sudo pip install molecule

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) edge"
sudo apt update
sudo apt install -y docker-ce
sudo pip install docker-py
```

### WSL and Docker
If you are using WSL and Docker on a VM, modify the docker config to have TCP listener enabled:

```bash
sudo systemctl edit docker
#[Service]
#ExecStart=
#ExecStart=/usr/bin/dockerd -H fd:// -H tcp://0.0.0.0:2375
```

On WSL, configure the host settings for Docker client:

```bash
DOCKER_HOST=127.0.0.1:2375
export DOCKER_HOST
```

molecule --base-config molecule/base.yml check


Role Variables
--------------

`packer_name`: Name for the template.

`packer_dest`: Target directory to create Packer template(s), additional file(s) and folder(s).

`packer_os_type`: OS family. Currently ony excepted value is `windows`.

`packer_options`: A dictionary/hashtable for packer template options.
  - `image`: (Optional|String) Image type. If provided, the role with read default settings from image configuration.
  - `builders`: (Optional|Dictionary) Packer builders
  - `provisioners`: (Optional|List) Packer provisioners
  - `variables`: (Optional|Dictionary) Packer variables
  - `sensitive-variables`: (Optional|List) Packer sensitive variables array

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: servers
      roles:
         - { role: username.rolename, x: 42 }

License
-------

MIT