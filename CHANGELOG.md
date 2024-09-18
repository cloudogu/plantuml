# Plantuml Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [v2023.10-5] - 2024-09-18
### Changed
- Relicense to AGPL-3.0-only

## [v2023.10-4] - 2024-08-07
### Changed
- [#23] Upgrade base-images to base:3.20.2-1 and java:11.0.24-1 

### Security
- close CVE-2024-41110

## [v2023.10-3] - 2024-06-28
### Changed
- Update base image to java:11.0.23-3 to use doguctl v0.12.0 (#21)

## [v2023.10-2] - 2024-02-08
### Added
- add dogu configuration key `logging/root` to the output control log level 

### Fixed
- log files no longer spam the container file system which lead to resource exhaustion in the host file system (#173)
  - generated log files (which formerly resided under `/opt/apache-tomcat/logs`) will now stream directly to the container's standard output (#16)
  - consequently all PlantUML logs flow right into the corresponding dogu log file on the host

## [v2023.10-1] - 2023-08-01
### Fixed
- Run PlantUML container no longer as privileged user (#14)

### Changed
- Update PlantUML to 1.2023.10 (#14)
- Update Apache Tomcat to 10.1.11 (#14)

## [v2023.6-1] - 2023-05-16
### Changed
- Update PlantUML to 1.2023.6 (#12)
- Update ces-build-lib to 1.62.2
- Update dogu-build-lib to v2.1.0
- Update makefiles to 7.5.0

## [v2022.4-2] - 2023-04-21
### Changed
- Update Java-Base-Image (#10)

## [v2022.4-1] - 2022-05-25
### Fixed
- Versioning of PlantUML Dogu using previous Version scheme

## [v1.2022.4-1] - 2022-05-25
### Changed
- Upgraded to PlantUML-Server version v1.2022.4

## [v2020.4-4] - 2022-04-06
### Changed
- Upgrade zlib package to fix CVE-2018-25032; #6

## [v2020.4-3] - 2022-02-07
### Changed
- Upgrade OpenJDK to 8u302

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
