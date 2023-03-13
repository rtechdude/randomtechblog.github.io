---
layout: post
title:  "AWS Terraform Setup"
date:   2023-02-01 12:47:15 -0600
categories: cool stuff
---
Terraform is a tool for building, changing, and versioning infrastructure safely and efficiently...at least according to ChatGPT.

I started messing around with it so I could quickly spin up EC2 instances.
Here are some quick instructions to get your workstation ready to terraform.

I utilized the Windows Linux Subsystem, so first, we need to install it along with Ubuntu.


From an elevated powershell prompt, run the command below and it should install both WLS and Ubuntu.

{% highlight bash %}
wsl --install -d ubuntu
{% endhighlight %}

Once Ubuntu is up and running, we need to install Terraform.

{% highlight bash %}
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common

wget -O- https://apt.releases.hashicorp.com/gpg | \
    gpg --dearmor | \
    sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg

gpg --no-default-keyring \
    --keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
    --fingerprint

echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
    https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
    sudo tee /etc/apt/sources.list.d/hashicorp.list

sudo apt update
sudo apt-get install terraform
{% endhighlight %}

You can test it by running “terraform” from the prompt

Now we need to install pip (python3 is bundled with Ubuntu, or at least it was for me)

{% highlight bash %}
sudo apt install python3-pip
{% endhighlight %}

Next install yawsso

{% highlight bash %}
python3 -m pip install --upgrade yawsso

export PATH="/home/<insert your username>/.local/bin:$PATH"
source ~/.bash_profile
{% endhighlight %}

Install AWS cli

{% highlight bash %}
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo apt-get install unzip -y
unzip awscliv2.zip
sudo ./aws/install
{% endhighlight %}

You will need an AWS config file which mine looks similar to whats below.


{% highlight bash %}
[profile prod]
region = us-east-1
output = yaml
[profile dev]
region = us-east-1
output = yaml
{% endhighlight %}

For more information check out AWS doc https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html

Thanks for reading!
I hope this helped you get started and on your way!
