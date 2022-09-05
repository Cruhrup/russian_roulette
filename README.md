# Russian Roulette in AWS
A simple Terraform project that spins up an EC2 instance, downloads russian_roulette.py, runs it, and shuts down the instance if the random number lands on 1.

#### Prerequisites
1. Download AWS CLI using the below instructions:
https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html

2. Download Terraform using the below instructions:
https://learn.hashicorp.com/tutorials/terraform/install-cli

3. Generate a keypair using `ssh-keygen -t rsa -b 4096 -f ~/.ssh/mykey_name`

4. In main.tf, modify the AWS provider section to point to the name of your AWS profile in `~/.aws/config` or `~/.aws/credentials` (provider name by default will be [default])

5. In main.tf, paste the public key into aws_key_pair section. Copying the public key can be done via `cat ~/.ssh/mykey_name.pub`

6. Run `terraform init` in the GitHub repository once you have pulled it down

7. Run `terraform apply -auto-approve` and once this has completed, you can either see the results of the roulette by looking at the EC2 instance in the AWS Console or SSH in by running `ssh -i "~/.ssh/my_key_name" ec2-user@public-ip`

#### Features

###### Random_Pet
This is a resource and provider being called upon to dynamically name EC2 instances. Some settings you can tweak are `length` as well as `prefix`. I've found the best naming scheme in using 3 for the `length`.

###### Russian_Roulette.py
The simple meme script that started this project. The original code was meant to delete `C:\Windows\System32` in using the `.remove` method from os. This script can be modified to do all sorts of fun things, if the number lands on 1. Another setting you may change is the `.randint()` method to have more or less odds. The first number represents the start of the range, and the second being the end of the range to call upon a random number.

#### Future Feature List

Ideally, some script named feeling_lucky.py in the repository that can ask user input on how many times russian_roulette.py should be recalled. This script should SSH to the provided instance public IP to call the roulette.

Multi-Cloud support? Maybe..

favorite pet names:
> the-hideously-noble-grouse,
> the-jolly-strong-silkworm