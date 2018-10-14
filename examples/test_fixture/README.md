# Test fixture for the Template Module

Terraform code in this directory calls the module that you are developing in the root of the repo.

## Usage

To run the tests, from the repo root execute:

```bash
$ kitchen test
...
Finished in 4.25 seconds (files took 2.75 seconds to load)
20 examples, 0 failures

       Finished verifying <default-aws> (0m9.03s).
-----> Kitchen is finished. (0m9.40s)
```

This will destroy any existing test resources, create the resources afresh, run the tests, report back, and destroy the resources.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
|      |             |      |       |       |

## Outputs

| Name | Description |
|------|-------------|
|      |             |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
