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
