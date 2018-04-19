Paypoc
======

About
-----
This repo contains an example set of [Terraform](https://www.terraform.io/) modules and [Lambda](https://aws.amazon.com/lambda/) functions to experiment with payment handling.  This is a proof of concept.  It's not designed to handle any payments, so please do not use any real card details.

Getting started
---------------

This repo is designed to be a simple starting point for infrastructure-as-code projects.  Invariably, you'll need some tools to build that infrastructure and credentials to secure access to it.  The setup of both is described here:

* [Getting set up guide [.md]](docs/getting_set_up.md) - how to set up your environment for instantiating infrastructure using the code in this repo

If you've used the default key name and path (described [above](docs/getting_set_up.md)), then to see what terraform plans to build out in the default region (eu-west-2):
```
terragrunt plan
```

If it seems sensible, apply it:
```
terragrunt apply
```

Look at what you've created in the AWS console!


Shutting down
-------------

Most important of all while developing IAC, clear it up afterwards:
```
terragrunt destroy
```
In general, this command doesn't remove all the possible resource types provisioned by Terraform (e.g. Packer AMIs, EC2 Volumes etc.), but it does remove all the resources provisioned as part of this project.

File structure
--------------
This repo is organised at the top-level by technology.

* [/bin](/bin) - a few scripts to hold useful commands for reference
* [/docs](docs) - markdown-formatted documents describing the examples in this repo

Provisioning

* [/terraform](/terraform) - a collection of modules to provision machines, linked from single root module [main.tf](/terraform/main.tf). 
  * [lamdba](/terraform/lambda) - a terraform module to create lambda functions
  * [static](/terraform/static) - a terraform module to put a static HTML website in S3

Function-as-a-service

* [/kotlin](/kotlin) - Kotlin source code to generate a 'fat' jar for execution as an AWS lambda function

Static HTML

* [/static](/static) - a simple HTML front-end to submit requests to the Lambda functions


Testing
-------

The terraform run outputs sample URLs that can be used for manual testing.

[/nodejs/loadtest.js](/nodejs/loadtest.js) - a work-in-progress lambda-based load test function

Documentation
-------------

We've taken the same simple approach to documentation.  It's all in markdown-formatted .md files, linked directly from this README.md.

* [Getting set up [.md]](docs/getting_set_up.md) - guide to setting up your terraform machine (local or remote)
  * [Pre-requisites [.md]](docs/pre_requisites.md)
  * [AWS permissions [.md]](docs/aws_permissions.md)
