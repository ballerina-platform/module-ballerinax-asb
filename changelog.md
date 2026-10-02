# Changelog

This file contains all the notable changes done to the Ballerina WebSub package through the releases.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Fixed
- Upgrade Azure Service Bus SDK to 7.18.0 to preserve subscription time-to-live updates, with aligned supporting libraries.
- Preserve the Service Bus error reason when the synchronous receiver wraps an exception.
- Run queue dead-letter tests before later tests enable dead-letter forwarding on the shared queue.
- Upgrade Jackson dependencies to 2.18.11 to address CVE-2026-91776 and CVE-2026-91777.
- Upgrade Netty to 4.1.137.Final to address the reported codec, HTTP, DNS, transport, and handler vulnerabilities, including CVE-2026-75595.
- Upgrade Azure Service Bus SDK to 7.17.7 and AMQP core to 2.9.12 to handle idle connection errors without Reactor dropped-error logs.
- Upgrade Jackson dependencies to 2.18.10 to address CVE-2026-68497, CVE-2026-19032, and CVE-2026-83557 in jackson-databind.
- [Fix `updateRule` not applying filter and action changes due to incorrect field extraction from nested `SqlRule` record](https://github.com/ballerina-platform/ballerina-library/issues/8730)

## [3.8.2] - 2024-10-01

### Fixed
- [Application written with `ballerina/asb` connector gives a conflicting JAR warning with `netty-buffer` and `jackson-annotations`](https://github.com/ballerina-platform/ballerina-library/issues/7061)

## [3.8.1] - 2024-09-30

### Fixed

- [When importing `ballerinax/asb` to package, a conflicting JAR warning is getting printed](https://github.com/ballerina-platform/ballerina-library/issues/7052)

### Changed

- [Implement ASB sender/receiver client actions in a non-blocking way](https://github.com/ballerina-platform/ballerina-library/issues/4982)
- [Improve Azure service bus administrator client actions to work in a non-blocking manner](https://github.com/ballerina-platform/ballerina-library/issues/6603)

## [3.8.0] - 2024-05-31

### Added

- [Add the listener-service implementation of the Azure service-bus connector](https://github.com/ballerina-platform/ballerina-library/issues/6495)
