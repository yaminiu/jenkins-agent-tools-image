set -e
# exit on any command failure

# basic package install checks
whoami
pwd
make --version
curl --version
python3 --version
ansible-playbook --version
aws --version
credstash --help
trivy --version
rsync --version
jq --version

echo ALL TESTS PASSED