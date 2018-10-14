# AWS Terraform Module Template

This repo is meant to provide a starting point for Terraform Module development in AWS.

It comes with the following pre-assembled:
 * a ruby environment in the Gemfile and `.ruby-version`
 * mostly blank module code files (`main.tf`, `variables.tf`, `outputs.tf`)
 * a test fixture to call the module in the `./examples/` directory
 * a test harness using [Test Kitchen](https://kitchen.ci/) and the [AWS SDK for Ruby](https://aws.amazon.com/sdk-for-ruby/) that can be found in `.kitchen.yml` and the `./test/` directory

## Usage

Clone or fork this repository into your own workstation, `cd` into the resulting directory, setup your ruby, and run `kitchen test` from the root of the repo. 

Kitchen should run without errors; your ruby environment may need tweaking using a tool like [RVM](https://rvm.io/) or [rbenv](https://github.com/rbenv/rbenv)

```bash
$ git clone git@github.com:grggls/terraform-module-template.git new-module
$ cd new-module
$ cat .ruby-version
2.4.2
$ rbenv local 2.4.2
$ ruby --version
ruby 2.4.2p198 (2017-09-14 revision 59899) [x86_64-darwin17]
$ bundle install
$ kitchen test
```

Having done that, your next steps should include updating the remote in this git repository, updating a couple of file and directory names to refer to your project (rather than 'template'), and start writing Terraform code!

## Explanation

We wanted a starting point for Terraform module development that was simple, extensible, and reusable.

Test Kitchen provides a test runner which is easy to understand and work with

```bash
$ cat .kitchen.yml
---
driver:
  name: "terraform"
  root_module_directory: "examples/test_fixture"

provisioner:
  name: "terraform"

platforms:
  - name: "aws"

verifier:
  name: "awspec"

suites:
  - name: "default"
    verifier:
      name: "awspec"
      patterns:
      - "test/integration/default/test_module_template.rb"
```

Somewhat pedantically, we describe to Test Kitchen that we're doing Terraform development in AWS and would like to write our test cases in [`awspec`](https://github.com/k1LoW/awspec).

We'll have Test Kitchen make use of the shell local [AWS CLI environment](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html).

Test Kitchen will execute the Terraform code in `root_module_directory: "examples/test_fixture"` where we call your Terraform module from a relative path. As your Terraform module takes shape, its changing usage (say with the addition of required variables), should be reflected here.

```bash
$ cat ./examples/test_fixture/main.tf
provider "aws" {
  region = "${var.region}"
}

data "aws_availability_zones" "available" {}

module "module_template" {
  source             = "../.."
  name               = "my_module"

  tags = {
    Owner       = "user"
    Environment = "dev"
  }
}
```

As AWS resources are added to your module, the number and types of tests executed using the Ruby AWS SDK should change. Here we do some basic unit tests of the Terraform in the module template, ensure we can parse the state file which results from its execution, and verify that the AWS CLI environment is connected to the AWS API by creating a client and making a simple API call:

```ruby
cat ./test/integration/default/test_module_template.rb
# frozen_string_literal: true

require 'awspec'
require 'aws-sdk'
require 'rhcl'

# should strive to randomize the region for more robust testing
example_main = Rhcl.parse(File.open('examples/test_fixture/main.tf'))
state_file = 'terraform.tfstate.d/kitchen-terraform-default-aws/terraform.tfstate'
tf_state = JSON.parse(File.open(state_file).read)

module_template_name  = example_main['module']['module_template']['name']
user_tag              = example_main['module']['module_template']['tags']['Owner']
environment_tag       = example_main['module']['module_template']['tags']['Environment']
region                = tf_state['modules'][0]['outputs']['region']['value']

ENV['AWS_REGION'] = region

ec2 = Aws::EC2::Client.new(region: region)
azs = ec2.describe_availability_zones
zone_names = azs.to_h[:availability_zones].first(2).map { |az| az[:zone_name] }
```
