# CHANGELOG

This file is used to list changes made in each version of the unbound cookbook.

## Unreleased

## 2.0.1 - *2021-06-01*

- Updated tests folder to match other cookbooks
- Updated spec platform to supported version

## 2.0.0 - 2020-05-05

- Upgraded to circleci for testing
- Minimum Chef Infra Client version is now **13.0**
- Removed unused long_description metadata.rb field
- Simplify overly complex platform logic
- Migrate to actions for testing

## [1.0.1]

- Simplify logic with root_group
- Fix `root_group` not using new_resource
- Use strings for file modes
- Resolve foodcritic warnings in the `rr` resource
- Fix platform_family logic on the service Update platforms.
- Use dokken images for travis testing.
- Don't test on debian-8/9 and centos-6 as these services don't currently start.
- Account for a list of forward-addrs / effectively disable remote control (#27)

## [1.0.0]

- Add new custom resources `unbound_install` & `unbound_configure`

## [0.1.1]

- Adding support and kitchen testing for forward_zone generation
- Updating to use Sous Chefs guidelines
