# Plantuml Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [v2020.4-2] - 2020-12-14
### Changed

- Upgraded the java base image to version `8u252-1`

### Added

- Added the ability to configure the memory limits with `cesapp edit-config`
- Ability to configure the `MaxRamPercentage` and `MinRamPercentage` for the PlantUML process inside the container via `cesapp edit-conf` (#3)

## [v2020.4-1] - 2020-04-06
### Added
- Jenkinsfile
- goss tests
- Docker healthcheck
- Multi-stage build in Dockerfile

### Changed
- Upgrade to PlantUML 1.2020.4
- Upgrade to tomcat 9.0.33
- Upgrade to java 11.0.5-1 base image