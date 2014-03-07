== Pickwick-Chef

Chef cookbooks for configuring servers for API, Workers and APP.

=== Build new server for APP

```
knife ec2 server create \
            --node-name pickwick-app --tags Role=app \
            --ssh-user ec2-user \
            --groups frontend --image ami-8fb7b2fb --flavor t1.micro --region eu-west-1 --availability-zone eu-west-1a \
            --distro amazon \
            --run-list 'role[app]'
```