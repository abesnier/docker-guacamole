[![Docker Pulls](https://img.shields.io/docker/pulls/abesnier/guacamole.svg?logo=docker)](https://hub.docker.com/r/abesnier/guacamole/)
[![Docker Stars](https://img.shields.io/docker/stars/abesnier/guacamole.svg?logo=docker)](https://hub.docker.com/r/abesnier/guacamole/)
[![GitHub Issues](https://img.shields.io/github/issues-raw/abesnier/docker-guacamole.svg)](https://github.com/abesnier/docker-guacamole/issues)


**If you decide to try the new images, make sure to delete the previous extensions. Go to the `config/guacamole/extensions` directory, and delete the files that contain 1.4.0 in their names (**`rm *1.4.0*.jar`**). Having multiple versions of the same extension will create issues. You can similarly clean the `extensions-available`.**

**This is a fork of oznu/docker-guacamole, updated to tomcat 9.0.&ast; (guacamole is not compatible with tomcat10), postgresql 13/14/15/16/17 (see below), guacamole 1.6.0, and s6_overlay 3.2.**

**If you are looking to upgrade from Oznu's image, or from an image that uses a version of PostgreSQL lower than 13, please have a look at the  [upgrade instructions](https://GitHub.com/abesnier/docker-guacamole/blob/master/UPGRADE.md). It is written for my images, but can be adapted for any image.**

**Every month, inactive images on Docker Hub will be removed. If you use one of those, you'll need to update to a newer image.**  If you need to keep a specific image, please raise an [Issue](https://GitHub.com/abesnier/docker-guacamole/issues), so I can track it.


# Summary of images
Base OS | PostgreSQL 13 | PostgreSQL 14 | PostgreSQL 15 | PostgreSQL 16 | PostgreSQL 17
---|---|---|---|---|---
Bullseye | guacamole:1.5.5-bullseye | N/A | N/A | N/A | N/A
Bullseye | guacamole:1.6.0-bullseye | N/A | N/A | N/A | N/A
Ubuntu | guacamole:1.5.5 | guacamole:1.5.5-pg14 | guacamole:1.5.5-pg15 | guacamole:1.5.5-pg16 | guacamole:1.5.5-pg17 
Alpine | N/A | guacamole:1.5.5-alpine | guacamole:1.5.5-alpine-pg15 | guacamole:1.5.5-alpine-pg16 | guacamole:1.5.5-alpine-pg17
Ubuntu | guacamole:1.6.0 <br> guacamole:latest | guacamole:1.6.0-pg14 <br> guacamole:latest-pg14 | guacamole:1.6.0-pg15 <br> guacamole:latest-pg15 | guacamole:1.6.0-pg16 <br> guacamole:latest-pg16 | guacamole:1.6.0-pg17 <br> guacamole:latest-pg17
Alpine | N/A | guacamole:1.6.0-alpine | guacamole:1.6.0-alpine-pg15 | guacamole:1.6.0-alpine-pg16 | guacamole:1.6.0-alpine-pg17
Built from Github | guacamole:github <br> guacamole:github-pg13 | guacamole:github-pg14 | guacamole:github-pg15 | guacamole:github-pg16 | guacamole:github-pg17

# What's new / Changelog
**2025-10-14** - Updated to Tomcat 9.0.111

**2025-10-08** - Updated to Tomcat 9.0.110

**2025-09-22** - Updated to PostgreSQL JDBC 42.7.8

**2025-09-08** - Updated to Tomcat 9.0.109

**2025-08-25** - Updated to Tomcat 9.0.108

**2025-07-23** - Remove the bullseye-backports from the bullseye's images, because the repos do not exist anymore. I may remove this image altogether...

**2025-07-15** - Finally took the time to update this README with the proper tags for 1.6.0...

**2025-07-07** - Updated to Tomcat 9.0.107

**2025-06-24** - Updated to Guacamole 1.6.0!! See the available tags to know which version to use. I'll update this readme a bit later.

**2025-06-12** - Updated to PostgreSQL JDBC 42.7.7

**2025-06-11** - Updated to Tomcat 9.0.106

**2025-06-02** - Updated to PostgreSQL JDBC 42.7.6

**2025-05-28** - Added github-*-noble images (see [note below in the "Something's not working" section](https://github.com/abesnier/docker-guacamole?tab=readme-ov-file#ive-updated-to-the-noble-images-and-i-get-postgresql-errors-whats-wrong)). They are still using all the same components, but are based on Ubuntu Noble instead of Jammy, and use FreeRDP 3 instead of FreeRDP 2.

**2025-05-15** - All images updated to Tomcat 9.0.105

**2025-05-13** - Updated to S6 Overlay 3.2.1.0, and Tomcat 9.0.105 for Alpine (not the other images)

**2025-05-07** - Updated to S6 Overlay 3.2.0.3

**2025-04-04** - Updated to Tomcat 9.0.104

**2025-04-09** - There was an issue with installing PostgreSQL 14 under Alpine Edge, so Alpine image with PG14 is forced to use Alpine 3.20.

**2025-03-07** - Updated to Tomcat 9.0.102

**2025-03-06** - Updated to Tomcat 9.0.100

**2025-02-11** - Updated to Tomcat 9.0.99

<details>
<summary>Older changelog entries</summary>

**2025-02-07** - Re-tagged the alpine based images, shorter names.

**2025-01-30** - Modified start-up script to remove all extensions from the extensions directory. This will prevent old versions to remain unused, and any way, extensions are populated back at start up from the image.

**2025-01-21** - Modified building process by simplifying Dockerfiles and docker-compose, etc... This allows me to build faster and save CPU usage! This does not change the content of the images, but will allow me to update faster! 

**2025-01-20** - PG17 images seem to be working ok, so please consider them available. Also, updated to PostgreSQL JDBC 42.7.5.

**2025-01-15** - Testing images with PostGreSQL 17 (alpine, ubuntu and github variants)

**2024-12-10** - Updated to Tomcat 9.0.98

**2024-10-11** - Updated to Tomcat 9.0.96 and S6 Overlay 3.2.02

**2024-09-26** - Updated to Tomcat 9.0.95

**2024-08-21** - Updated to Tomcat 9.0.94

**2024-09-04** - Fixed an issue with PostgreSQL 16 images ([Issue #40](https://GitHub.com/abesnier/docker-guacamole/issues/40))

**2024-08-26** - Updated to PostgreSQL JDBC 42.7.4

**2024-08-21** - Updated to Tomcat 9.0.93, and added images for Postgresql 16 (suffixed with pg16)

**2024-07-12** - Updated with fix from WindoC ([Issue #38](https://GitHub.com/abesnier/docker-guacamole/issues/38))

**2024-07-09** - Updated to Tomcat 9.0.91

**2024-05-15** - Updated to Tomcat 9.0.89

**2024-04-22** - Updated to Tomcat 9.0.88

**2024-04-09** - Updated to Guacamole 1.5.5

**2024-03-20** - Updated to Tomcat 9.0.87 and PostgreSQL JDBC 42.7.3

**2024-02-22** - Updated to Tomcat 9.0.86 and PostgreSQL JDBC 42.7.2

**2024-02-02** - Added sso-ssl extension for the Github images (see below)

**2024-02-01** - Updated Guacamole to 1.5.5 for the Github images

**2024-01-10** - Updated to Tomcat 9.0.85

**2023-12-14** - Updated to Tomcat 9.0.84

**2023-12-11** - Updated to Guacamole 1.5.4

**2023-12-07** - Updated to PostgreSQL JDBC 42.7.1

**2023-11-21** - Updated to S6 Overlay 3.1.6.2 and PostgreSQL JDBC 42.7.0

**2023-11-20** - Updated to S6 Overlay 3.1.6.1

**2023-11-16** - Updated to Tomcat 9.0.83

**2023-11-07** - Updated to S6 Overlay 3.1.6.0

**2023-10-16** - Updated to Tomcat 9.0.82

**2023-10-12** - Updated to Tomcat 9.0.81

**2023-10-10** - Hopefully fixing an issue with S6 Overlay and armhf architectures.

**2023-09-21** - Another update related to [Issue #22](https://GitHub.com/abesnier/docker-guacamole/issues/22): I've implemented the REMOTE_IP_VALVE_ENABLED environment variable, as it is used with the official Guacamole Client docker. This is useful when Guacamole is used behind a reverse proxy, to make the real client ip visible instead of the proxy's one. See the [documentation](https://guacamole.apache.org/doc/gug/guacamole-docker.html#running-guacamole-behind-a-proxy)

**2023-08-26** - Updated to Tomcat 9.0.80

**2023-08-19** - Updated to Tomcat 9.0.79

**2023-08-08** - I decided to rename the `github` tag, and include versions with different flavours of PostgreSQL (13, 14 and 15). So the new tags are `github-pg13` (or `github`), `github-pg14` and `github-pg15`. They are based on the `latest`, `latest-pg14` and `latest-pg15` tags, and will be updated regularly as the other images. They also come with two new extensions, that are not very well documented as of today, see the extensions sections below for more details.

**2023-08-07** - Created a new tag `latest-github` (based on the `latest` tag). This tag was created because the Guacamole Client that is available on the official website omits a lot of changes that have been pushed to GitHub. The client and the extensions are built outside docker, and the source code will be uploaded on my GitHub if anyone needs to audit it. See [Issue #23](https://GitHub.com/abesnier/docker-guacamole/issues/23). This tag will be updated weekly, like the other ones.

**2023-05-31** - Updated to Guacamole 1.5.3

**2023-07-13** - Updated to Tomcat 9.0.78

**2023-06-14** - Ok, my previous fix for issue #16 did not work at all. Also, I noticed that if you enabled an extension and then tried to disable it, it would not work. That last bug went unnoticed since I forked Oznu's image and started working on it!

**2023-06-12** - Updated to Tomcat 9.0.76

**2023-06-07** - :warning: It seems that Guacamole 1.5.2 [can segfault on some RDP connections](https://lists.apache.org/thread/ws7xykpm2cmnz2w42y9qy8kkn6hdpr0x). If you encounter that bug, please hold on for a bit until the Guacamole Team fixes it (and that will probably not take long).

**2023-06-06** - FIX: Extensions were not properly cleaned between Guacamole versions bumps. This could create issues for example with multi-factor authentication. CAVEAT: if you use custom extensions, please make sure they contain the correct Guacamole version in their name (which was already the case to be honest). Thanks q20 for reporting the [issue](https://GitHub.com/abesnier/docker-guacamole/issues/16).

**2023-05-31** - Updated to Guacamole 1.5.2

**2023-05-24** - Updated to Tomcat 9.0.75, S6 Overlay 3.1.5.0. Also added images that use PostgreSQL 15 (with Ubuntu and Alpine bases). Be careful! These images cannot be used as in-place replacement for another version of PostgreSQL, you need to follow [upgrade instructions](https://GitHub.com/abesnier/docker-guacamole/blob/master/UPGRADE.md) (and backup and double backup!)

**2023-04-17** - Updated to Guacamole 1.5.1 Release. The previous build was done with 1.5.1 Release Candidate only. Make sure to purge older extensions (1.4.0, 1.5.0, etc.. from the /config/guacamole/extensions and extensions-available directories before restarting the container.

**2023-04-11** - Updated to Guacamole 1.5.1. This is a bugfix release that addresses regressions noted in the 1.5.0 release. For a full list of all changes in this release, please see the [changelog](https://guacamole.apache.org/releases/1.5.1/#changelog).

**2023-04-02** - Updated to S6 Overlay 3.1.4.2.

**2023-03-19** - Updated to PostgreSQL JDBC 42.6.0

**2023-03-07** - Added a paragraph in the [Something's not working](https://GitHub.com/abesnier/docker-guacamole#somethings-not-working-what-to-do) section, to explain how to use the new history recording extension. Thank you [lfac76](https://GitHub.com/abesnier/docker-guacamole/issues/11) for the suggestion. 

**2023-03-06** - Updated to Tomcat 9.0.73

**2023-02-27** - Updated to final Guacamole 1.5.0, Tomcat 9.0.72, and S6 Overlay 3.1.4.1.

**2023-02-16** - Updated to PostgreSQL JDBC 42.5.4

**2023-02-15** - I noticed there is a Release Candidate for Guacamole 1.5.0. So I created new images. Let's see how they work. If you try them, and notice something odd, please report the [issue](https://GitHub.com/abesnier/docker-guacamole/issues)!

**2023-02-15** - Well, of course, PostgreSQL JDBC 42.5.3 comes back online just two days after I regressed the images... Soooo, here they are back, updated with 42.5.3.

**2023-02-13** - PostgreSQL JDBC 42.5.3 is still available for download, but is not visible from the download page, so I'll assume there is a regression, and decided to downgrade to 42.5.2.

**2023-02-06** - Updated to PostgreSQL JDBC 42.5.3. 

**2023-02-01** - Updated to PostgreSQL JDBC 42.5.2.

Images are now built with the `--provenance=false` flag, to mitigate issue with manifests and WatchTower (thanks to the users referencing my image in WatchTower by the way!). See [here](https://GitHub.com/containrrr/watchtower/discussions/1529) for details.

**2023-01-23** - Updated to S6 Overlay 3.1.3.0

**2023-01-14** - Updated to Tomcat 9.0.71

**2022-12-13** - Added support for the environment variable "GUACD_LOG_LEVEL" for all images, to match with the official Guacamole Image, and provide users a way to debug their application.

The value is set by default to `info`. The valid values are `error`, `warn`, `info`, `debug` and `trace`. See the [Official documentation](https://guacamole.apache.org/doc/gug/configuring-guacamole.html?logging-within-the-web-application#logging-within-the-web-application) for more details.

The variable can be set either by adding `-e GUACD_LOG_LEVEL=debug` to your `docker run` command, or in the environment section of your `docker-compose.yml` file. 

**2022-12-08** - Updated to Tomcat 9.0.70

**2022-11-27** - Updated to PostgreSQL JDBC 42.5.1

**2022-11-16** - Updated to Tomcat 9.0.69

**2022-11-09** - Added support for arm/v7 and ppc64el for supported images (both for `alpine` and `latest-pg14`, ppc64el only for `latest`, and nothing new for `bullseye`). 

**2020-10-21** - Created a new image, `alpine`. The idea was to have a smaller image. It is about 40% smaller than the `latest` image.

This image is based on Alpine Edge, and uses PostgreSQL 14 and S6 overlay.

As far as I tested it, it can be used as a replacement for a previous PostgreSQL 14 image (`guacamole:1.4.0-pg14` or `guacamole:latest-pg14`).

It has been tested as far as I could, but in case of issue, as usual, please report the [issues](https://GitHub.com/abesnier/docker-guacamole/issues).

**2022-10-20** - Added a Docker HEALTHCHECK. Containers will report their health status every minute.

**2022-10-10** - Ubuntu-based images updated to Tomcat 9.0.68 (latest, latest-pg14, 1.4.0, 1.4.0-pg14).

**2022-09-27** - Ubuntu-based images updated to Tomcat 9.0.67 (latest, latest-pg14, 1.4.0, 1.4.0-pg14).

It seems the Bullseye-based Tomcat images will not be maintained anymore by the Docker Community (see [this commit](https://GitHub.com/docker-library/tomcat/commit/2133bd5eb90e808de7dc51e5e980091e765af90b)), and therefore, the bullseye image will disappear from my repo too, as I intend to only keep up-to-date images.

Replacement from 1.4.0-bullseye to 1.4.0 is one-to-one, and works without disrupting the user space. If you are using `abesnier/guacamole:1.4.0-bullseye` or `latest-bullseye`, just drop the `-bullseye` from your command line or your `docker-compose.yml` and it will be transparent next time you start your container.

**2022-08-30** - All tags updated to S6 Overlay v3.1.2.1.

**2022-08-29** - All tags updated to S6 Overlay v3.1.2.0.

**2022-08-24** - All tags updated to PostgreSQL JDBC 42.5.0 (yes, the same day I updated them to 42.4.2, the wonderful PostgreSQL JDBC team released another version...)

**2022-08-24** - All tags updated to PostgreSQL JDBC 42.4.2

**2022-08-09** - Added an extension `guacamole-branding-1.4.0.jar`. It now comes enabled by default, and its sole effect is to add links to the official Apache Guacamole webpage, to my GitHub, and to the issue page on GitHub.

The idea of this extension is to show that even a docker image can use the branding possibilities of Guacamole. If you have an existing branding extension, you can just drop it in the `config/guacamole/extensions` directory and restart the container.

**2022-08-05** - All tags reverted to PostgresJDBC 42.4.0, as it appears images cannot start properly with 42.4.1. I need to investigate why, but I noticed an fatal error during some random testing: 

`### Error querying database. Cause: java.sql.SQLException: Error setting driver on UnpooledDataSource. Cause: java.lang.ClassNotFoundException: org.postgresql.Driver`

So I decided to rebuild the image with 42.4.0. I will continue testing until resolved.

**2022-08-04** - All tags updated to PostgresJDBC 42.4.1

**2022-07-22** - All tags updated to Tomcat 9.0.65

**2022-07-01** - Follow up on moving from the base image to Ubuntu Jammy (22.04.4 LTS). The default postgresql package is in version [14.3](https://packages.ubuntu.com/jammy/postgresql), and if you inspect the Dockerfiles, you will see that I need to add the official postgres repository to be able to install postgresql-13.

I don't like that, as I am used to using Debian, and learnt not to mix repositories if you can avoid it.

So, I have created a new tag "latest-pg14" in order to test the upgrade process. And it is surprisingly easy. Please have a look at the [upgrade instructions](https://GitHub.com/abesnier/docker-guacamole/blob/master/UPGRADE.md) for details, should you chose to upgrade.


**2022-06-30** - Well ,well, well, the base Tomcat image never ceases to amaze me! Since the last image re-build the base image has now moved to Ubuntu Jammy (22.04.4 LTS). This came with an unexpected surprise: OpenSSL has been upgraded to 3.0.2. This might seem innocuous, but the build process of Guacamole Server failed, as it relies on deprecated methods. Source code for Guacamole has already been updated on GitHub, but not the downloadable source tarball from the official website.

So, the latest tag is now built on the source code available on GitHub.

Oh, and by the way, updated to s6 overlay 3.1.1.2.

**2022-06-27** - New tags are available!  The philosophy for tomcat base image (i.e. 9.0.64-jre11) is to switch from openjdk to Temurin, but unfortunately, the build process failed with this base image. 9.0.64-jre11 used to be based on Debian Bullseye, but it is now based on Ubuntu 20.04.4 LTS. So I decided to create new tags:


* 1.4.0, latest : based on tomcat:9.0.64-jre11, which is based on Ubuntu 20.04.4 LTS

* 1.4.0-bullseye, latest-bullseye : based on tomcat:9.0.64-jre11-openjdb-slim-bullseye

* the *-bullseye images will work as before, and I have tested the Ubuntu-based ones as much as I could. Please report  [issues](https://GitHub.com/abesnier/docker-guacamole/issues) if any, I'll make my best to solve them as fast as possible! 

Oh, and by the way, updated to s6 overlay 3.1.1.1

**2022-06-10** - updated to tomcat 9.0.64 and PostgreSQL JDBC 42.4.0

**2022-05-11** - updated to PostgresJDBC 42.3.6

**2022-05-12** - updated to tomcat 9.0.63

**2022-05-12** - added a new tag: GitHub. This image is built on the GitHub repos for guacamole-server and guacamole-client.

**2022-05-11** - updated to PostgresJDBC 42.3.5

**2022-04-19** - updated to Tomcat 9.0.62 and PostgreSQL JDBC 42.3.4

**2022-03-16** - updated to tomcat 9.0.60, and fixed an issue that prevented the container to start on arm64

**2022-03-08** - updated to S6 Overlay 3.1.0.1

**2022-03-01** - updated to PostgresJDBC 42.3.3, tomcat 9.0.59, arm64 not supported by tomcat 9.0.59

**2022-02-22** - updated to s6 overlay 3.0.0.2-2

**2022-02-07** - updated to version Postegres JDBC driver 42.3.2

**2022-01-31** - s6 overlay 3.0.0.2 has been released, that corrects a bug in the management of environment variables. Images 1.4.0, 1.4.0-s6_v3 and latest have been updated to this version, as well as updated to Tomcat 9.0.58.

**2022-01-29** - I noticed a typo in the Dockerfile that introduced a bug with PostgreSQL JDBC Driver. Fixed in all tags. Issue #2

**2022-01-27** - updated to s6 overlay 3.0 and tomcat 9.0.58

**2022-01-03** - updated to version 1.4.0

</details>

# Available tags

`1.6.0`,`latest` , Guacamole **1.6.0** (server and client downloaded from [official website](https://guacamole.apache.org/releases/), based on [latest available Tomcat 9.0.*](https://hub.docker.com/_/tomcat/tags)(Ubuntu Jammy, Temurin OpenJDK JRE) base image at time of build, PostgreSQL **13**, [latest PostgreSQL JDBC Driver available](https://jdbc.postgresql.org/) at time of build, [latest S6 Overlay available](https://github.com/just-containers/s6-overlay/releases) at time of build

`1.6.0-pg14`,`latest-pg14` , Guacamole **1.6.0** (server and client downloaded from [official website](https://guacamole.apache.org/releases/), based on [latest available Tomcat 9.0.*](https://hub.docker.com/_/tomcat/tags)(Ubuntu Jammy, Temurin OpenJDK JRE) base image at time of build, PostgreSQL **14**, [latest PostgreSQL JDBC Driver available](https://jdbc.postgresql.org/) at time of build, [latest S6 Overlay available](https://github.com/just-containers/s6-overlay/releases) at time of build

`1.6.0-pg15`,`latest-pg15` , Guacamole **1.6.0** (server and client downloaded from [official website](https://guacamole.apache.org/releases/), based on [latest available Tomcat 9.0.*](https://hub.docker.com/_/tomcat/tags)(Ubuntu Jammy, Temurin OpenJDK JRE) base image at time of build, PostgreSQL **15**, [latest PostgreSQL JDBC Driver available](https://jdbc.postgresql.org/) at time of build, [latest S6 Overlay available](https://github.com/just-containers/s6-overlay/releases) at time of build

`1.6.0-pg16`,`latest-pg16` , Guacamole **1.6.0** (server and client downloaded from [official website](https://guacamole.apache.org/releases/), based on [latest available Tomcat 9.0.*](https://hub.docker.com/_/tomcat/tags)(Ubuntu Jammy, Temurin OpenJDK JRE)) base image at time of build, PostgreSQL **16**, [latest PostgreSQL JDBC Driver available](https://jdbc.postgresql.org/) at time of build, [latest S6 Overlay available](https://github.com/just-containers/s6-overlay/releases) at time of build

`1.6.0-pg17`,`latest-pg17` , Guacamole **1.6.0** (server and client downloaded from [official website](https://guacamole.apache.org/releases/), based on [latest available Tomcat 9.0.*](https://hub.docker.com/_/tomcat/tags)(Ubuntu Jammy, Temurin OpenJDK JRE) base image at time of build, PostgreSQL **17**, [latest PostgreSQL JDBC Driver available](https://jdbc.postgresql.org/) at time of build, [latest S6 Overlay available](https://github.com/just-containers/s6-overlay/releases) at time of build

`1.5.5` , Guacamole **1.5.5** (server and client downloaded from [official website](https://guacamole.apache.org/releases/), based on [latest available Tomcat 9.0.*](https://hub.docker.com/_/tomcat/tags)(Ubuntu Jammy, Temurin OpenJDK JRE) base image at time of build, PostgreSQL **13**, [latest PostgreSQL JDBC Driver available](https://jdbc.postgresql.org/) at time of build, [latest S6 Overlay available](https://github.com/just-containers/s6-overlay/releases) at time of build

`1.5.5-pg14`, Guacamole **1.5.5** (server and client downloaded from [official website](https://guacamole.apache.org/releases/), based on [latest available Tomcat 9.0.*](https://hub.docker.com/_/tomcat/tags)(Ubuntu Jammy, Temurin OpenJDK JRE) base image at time of build, PostgreSQL **14**, [latest PostgreSQL JDBC Driver available](https://jdbc.postgresql.org/) at time of build, [latest S6 Overlay available](https://github.com/just-containers/s6-overlay/releases) at time of build

`1.5.5-pg15`, Guacamole **1.5.5** (server and client downloaded from [official website](https://guacamole.apache.org/releases/), based on [latest available Tomcat 9.0.*](https://hub.docker.com/_/tomcat/tags)(Ubuntu Jammy, Temurin OpenJDK JRE) base image at time of build, PostgreSQL **15**, [latest PostgreSQL JDBC Driver available](https://jdbc.postgresql.org/) at time of build, [latest S6 Overlay available](https://github.com/just-containers/s6-overlay/releases) at time of build

`1.5.5-pg16`, Guacamole **1.5.5** (server and client downloaded from [official website](https://guacamole.apache.org/releases/), based on [latest available Tomcat 9.0.*](https://hub.docker.com/_/tomcat/tags)(Ubuntu Jammy, Temurin OpenJDK JRE)) base image at time of build, PostgreSQL **16**, [latest PostgreSQL JDBC Driver available](https://jdbc.postgresql.org/) at time of build, [latest S6 Overlay available](https://github.com/just-containers/s6-overlay/releases) at time of build

`1.5.5-pg17`, Guacamole **1.5.5** (server and client downloaded from [official website](https://guacamole.apache.org/releases/), based on [latest available Tomcat 9.0.*](https://hub.docker.com/_/tomcat/tags)(Ubuntu Jammy, Temurin OpenJDK JRE) base image at time of build, PostgreSQL **17**, [latest PostgreSQL JDBC Driver available](https://jdbc.postgresql.org/) at time of build, [latest S6 Overlay available](https://github.com/just-containers/s6-overlay/releases) at time of build

`alpine`,`alpine-pg14`,`1.5.5-alpine`,`1.5.5-alpine-pg14` , Guacamole **1.5.5** (server built from Github, client downloaded from [official website](https://guacamole.apache.org/releases/), based on [latest available Alpine Edge](https://hub.docker.com/_/alpine/tags?name=edge) base image at time of build, PostgreSQL **14**, [latest PostgreSQL JDBC Driver available](https://jdbc.postgresql.org/) at time of build, [latest S6 Overlay available](https://github.com/just-containers/s6-overlay/releases) at time of build

`1.5.5-alpine-pg15`,`alpine-pg15`, Guacamole **1.5.5** (server built from Github, client downloaded from [official website](https://guacamole.apache.org/releases/), based on [latest available Alpine Edge](https://hub.docker.com/_/alpine/tags?name=edge) base image at time of build, PostgreSQL **15**, [latest PostgreSQL JDBC Driver available](https://jdbc.postgresql.org/) at time of build, [latest S6 Overlay available](https://github.com/just-containers/s6-overlay/releases) at time of build

`1.5.5-alpine-pg16`,`alpine-pg16`, Guacamole **1.5.5** (server built from Github, client downloaded from [official website](https://guacamole.apache.org/releases/), based on [latest available Alpine Edge](https://hub.docker.com/_/alpine/tags?name=edge) base image at time of build, PostgreSQL **16**, [latest PostgreSQL JDBC Driver available](https://jdbc.postgresql.org/) at time of build, [latest S6 Overlay available](https://github.com/just-containers/s6-overlay/releases) at time of build

`1.5.5-alpine-pg17`,`alpine-pg17`, Guacamole **1.5.5** (server built from Github, client downloaded from [official website](https://guacamole.apache.org/releases/), based on [latest available Alpine Edge](https://hub.docker.com/_/alpine/tags?name=edge) base image at time of build, PostgreSQL **17**, [latest PostgreSQL JDBC Driver available](https://jdbc.postgresql.org/) at time of build, [latest S6 Overlay available](https://github.com/just-containers/s6-overlay/releases) at time of build

`1.5.5-bullseye` Guacamole **1.5.5** (server and client downloaded from [official website](https://guacamole.apache.org/releases/), based on [latest available Tomcat 9.0.* (Debian Bullseye, OpenJDK JRE)](https://hub.docker.com/_/tomcat/tags) base image at time of build, PostgreSQL **13**, [latest PostgreSQL JDBC Driver available](https://jdbc.postgresql.org/) at time of build, [latest S6 Overlay available](https://github.com/just-containers/s6-overlay/releases) at time of build

`github`, `github-pg13` , Guacamole **1.6.0** (server built from [Github](https://github.com/apache/guacamole-server), client downloaded from [official website](https://guacamole.apache.org/releases/), based on [latest available Tomcat 9.0.* (Ubuntu Jammy, Temurin OpenJDK JRE)](https://hub.docker.com/_/tomcat/tags) base image at time of build, PostgreSQL **13**, [latest PostgreSQL JDBC Driver available](https://jdbc.postgresql.org/) at time of build, [latest S6 Overlay available](https://github.com/just-containers/s6-overlay/releases) at time of build

`github-pg14` , Guacamole **1.6.0** (server built from [Github](https://github.com/apache/guacamole-server), client downloaded from [official website](https://guacamole.apache.org/releases/), based on [latest available Tomcat 9.0.* (Ubuntu Jammy, Temurin OpenJDK JRE)](https://hub.docker.com/_/tomcat/tags) base image at time of build, PostgreSQL **14**, [latest PostgreSQL JDBC Driver available](https://jdbc.postgresql.org/) at time of build, [latest S6 Overlay available](https://github.com/just-containers/s6-overlay/releases) at time of build

`github-pg15` , Guacamole **1.6.0** (server built from [Github](https://github.com/apache/guacamole-server), client downloaded from [official website](https://guacamole.apache.org/releases/), based on [latest available Tomcat 9.0.* (Ubuntu Jammy, Temurin OpenJDK JRE)](https://hub.docker.com/_/tomcat/tags) base image at time of build, PostgreSQL **15**, [latest PostgreSQL JDBC Driver available](https://jdbc.postgresql.org/) at time of build, [latest S6 Overlay available](https://github.com/just-containers/s6-overlay/releases) at time of build

`github-pg16` , Guacamole **1.6.0** (server built from [Github](https://github.com/apache/guacamole-server), client downloaded from [official website](https://guacamole.apache.org/releases/), based on [latest available Tomcat 9.0.* (Ubuntu Jammy, Temurin OpenJDK JRE)](https://hub.docker.com/_/tomcat/tags) base image at time of build, PostgreSQL **16**, [latest PostgreSQL JDBC Driver available](https://jdbc.postgresql.org/) at time of build, [latest S6 Overlay available](https://github.com/just-containers/s6-overlay/releases) at time of build

`github-pg17` , Guacamole **1.6.0** (server built from [Github](https://github.com/apache/guacamole-server), client downloaded from [official website](https://guacamole.apache.org/releases/), based on [latest available Tomcat 9.0.* (Ubuntu Jammy, Temurin OpenJDK JRE)](https://hub.docker.com/_/tomcat/tags) base image at time of build, PostgreSQL **17**, [latest PostgreSQL JDBC Driver available](https://jdbc.postgresql.org/) at time of build, [latest S6 Overlay available](https://github.com/just-containers/s6-overlay/releases) at time of build

** Note: the github images are also available in a *-noble variant, based on Ubuntu Noble instead of Jammy, to be able to use FreeRDP 3 instead of FreeRDP 2. **

## Stale/unmaintained tags

`test` compiled from available source code on GitHub for guacamole-client and guacamole-server.

`1.3.0` version 1.3.0, based on latest Tomcat, PostgresJDBC driver available at time of build, and S6 Overlay 2.2.0.3.

`1.4.0-s6_v3` updated to s6 overlay 3.0.0.0 and tomcat:9.0.58-jre11 (note: This image is built on a custom build of s6 overlay. It will be renamed as latest when s6 overlay is fixed and I can use the [release tarballs](https://GitHub.com/just-containers/s6-overlay/releases/).)

And any other tags still found on my Docker Hub tags page...

# Auto promo


If Guacamole is useful to you, do not hesitate to support the great work of the [Apache Foundation](https://donate.apache.org/).


On a side note, running the server I use to build these images, researching update info, maintaining the images, takes quite some time and a little money. I'll gladly accept [a coffee!](https://paypal.me/antoinebesnier)


# Docker Guacamole


A Docker Container for [Apache Guacamole](https://guacamole.apache.org/), a client-less remote desktop gateway. It supports standard protocols like VNC, RDP, and SSH over HTML5.


[![IMAGE ALT TEXT](http://img.youtube.com/vi/esgaHNRxdhY/0.jpg)](http://www.youtube.com/watch?v=esgaHNRxdhY "Video Title")


This container runs the guacamole web client, the guacd server and a postgres database.


## Usage


```shell

docker run \

  -p 8080:8080 \

  -v </path/to/config>:/config \

  abesnier/guacamole

```


## Parameters


The parameters are split into two halves, separated by a colon, the left hand side representing the host and the right the container side.


* `-p 8080:8080` - Binds the service to port 8080 on the Docker host, **required**

* `-v /config` - The config and database location, **required**

* `-e EXTENSIONS` - See below for details.


## Enabling Extensions


Extensions can be enabled using the `-e EXTENSIONS` variable. Multiple extensions can be enabled using a comma separated list without spaces.


For example:


```shell

docker run \

  -p 8080:8080 \

  -v </path/to/config>:/config \

  -e "EXTENSIONS=auth-ldap,auth-duo"

  abesnier/guacamole

```


Currently the available extensions are:


* auth-ldap - [LDAP Authentication](https://guacamole.apache.org/doc/gug/ldap-auth.html)

* auth-duo - [Duo two-factor authentication](https://guacamole.apache.org/doc/gug/duo-auth.html)

* auth-header - [HTTP header authentication](https://guacamole.apache.org/doc/gug/header-auth.html)

* auth-sso-cas - [CAS Authentication](https://guacamole.apache.org/doc/gug/cas-auth.html)

* auth-sso-openid - [OpenID Connect authentication](https://guacamole.apache.org/doc/gug/openid-auth.html)

* auth-totp - [TOTP two-factor authentication](https://guacamole.apache.org/doc/gug/totp-auth.html)

* auth-quickconnect - [Ad-hoc connections extension](https://guacamole.apache.org/doc/gug/adhoc-connections.html)

* auth-sso-saml - [SAML Authentication](https://guacamole.apache.org/doc/gug/saml-auth.html)

* auth-sso-ssl - [SSL/Smart cards authenticatition](https://github.com/apache/guacamole-client/pull/797)

* auth-sso - SSO Authentication metapackage, contains classes for CAS, OpenID and SAML authentication (see links above)

* auth-json - [Encrypted JSON Authentication](https://guacamole.apache.org/doc/gug/json-auth.html)

* history-recording-storage - [In-application playback of recordings](https://guacamole.apache.org/doc/1.5.1/gug/recording-playback.html)

* vault - [Support for retrieving secrets from key vaults](https://guacamole.apache.org/doc/1.5.1/gug/vault.html)

* auth-ban - [Extension for automatically blocking brute-force auth attempts](https://GitHub.com/apache/guacamole-client/pull/758)

* display-statistics - [Display graphics statistics at the bottom of the cielnt screen for remote desktop sessions (remote desktop fps, server fps, cleint fps, dropped frames)](https://GitHub.com/apache/guacamole-client/pull/681)

* [1.6.0] auth-restrict - [Advanced login and connection restrictions](https://guacamole.apache.org/doc/gug/auth-restrict.html). Allows the admin to restrict when a user is allowed to connect, and when a connection is available to an user.

You should only enable the extensions you require, if an extensions is not configured correctly in the `guacamole.properties` file it may prevent the system from loading. See the [official documentation](https://guacamole.apache.org/doc/gug/) for more details.


## Default User


The default username is `guacadmin` with password `guacadmin`.


## Windows-based Docker Hosts


Mapped volumes behave differently when running Docker for Windows and you may encounter some issues with PostgreSQL file system permissions. To avoid these issues, and still retain your config between container upgrades and recreation, you can use the local volume driver, as shown in the `docker-compose.yml` example below. When using this setup be careful to gracefully stop the container or data may be lost.


```yml

version: "3"

services:

  guacamole:

    image: abesnier/guacamole

    container_name: guacamole

    volumes:

      - /local_path_config_directory:/config

    ports:

      - 8080:8080

```

See [docker-compose.yml](https://GitHub.com/abesnier/docker-guacamole/blob/master/docker-compose.yml) for more details


## Something's not working, what to do?

### I've updated to the Noble images, and I get POSTGRESQL errors, what's wrong?
Thanks to [SirOch27](https://github.com/abesnier/docker-guacamole/issues/49) for reporting this oversight from my part.

Between Jammy and Noble, the collation version of PSQL has been updated. Therefore, if you are upgrading in place, you may see such messages in your logs:

```
2025-06-03 13:01:34.973 CEST [190] WARNING: database "guacamole_db" has a collation version mismatch
2025-06-03 13:01:34.973 CEST [190] DETAIL: The database was created using collation version 2.35, but the operating system provides version 2.39.
2025-06-03 13:01:34.973 CEST [190] HINT: Rebuild all objects in this database that use the default collation and run ALTER DATABASE guacamole_db REFRESH COLLATION VERSION, or build PostgreSQL with the right library version.
WARNING: database "guacamole_db" has a collation version mismatch
```

The fix is very easy, you can run this simple one-liner:

`docker exec -it guacamole sh -c "runuser -u postgres -- psql -c 'ALTER DATABASE guacamole_db REFRESH COLLATION VERSION;'"`



### Guacamole does not show the real IP, but the docker interface one's
There are multiple ways to show the real IP of the users, and it depends on your network configuration, and/or docker configuration.

I have implemented Guacamole's REMOTE_IP_VALVE_ENABLED environment variable. See the [documentation](https://guacamole.apache.org/doc/gug/guacamole-docker.html#running-guacamole-behind-a-proxy)

For example, [Issue #22](https://GitHub.com/abesnier/docker-guacamole/issues/22) shows you a solution to show the clients IP behind a Cloudflare tunnel.


### I upgraded to a newer version of Guacamole and/or PostegreSQL, and 2FA Authentication does not work anymore.
It is possible that after some upgrades, either in the Guacamole version, or to a newer PostgreSQL version (13 to 14 or 15 or higher, after you carefully follow the [instructions here](https://GitHub.com/abesnier/docker-guacamole/blob/master/UPGRADE.md) for example), you are faced with an error message after entering your TOTP token. Guacamole will display the message "Verification failed. Please try again.".

There are multiple causes to this issues I believe.

The first one was a slight oversight from my part during start-up of the container, and you are left with multiple versions of some extensions. Go to your /config/guacamole/extensions, and delete all extensions that do not contain the correct Guacamole version (1.5.2 at the time of writing this). This issue is now fixed, and extensions should be properly cleaned when the container starts again. So restart the container, and that should be it.

If cleaning does not solve the issue, then you will have to reset the TOTP secret for at least one admin user. This can be done in a one-liner:
`docker exec -it guacamole bash -c "psql -U guacamole guacamole_db -c \"UPDATE guacamole_user_attribute SET attribute_value='false' WHERE attribute_name = 'guac-totp-key-confirmed' and user_id = (SELECT user_id FROM guacamole_user INNER JOIN guacamole_entity ON guacamole_entity.entity_id = guacamole_user.entity_id WHERE guacamole_entity.name = 'your username');\""`

Once executed, try to login with the user name you specified, and you will be prompted to register your MFA again: 

![MFA Enrollment](https://guacamole.apache.org/doc/gug/_images/totp-enroll.png "MFA Enrollment prompt")

When your admin user has recovered access, he can go tio the admin panel and reset TOTP secret for other users. This will force users to re-enroll. See [documentation here](https://guacamole.apache.org/doc/gug/totp-auth.html#reseting-totp-data).


### I can't find the session recordings in the History panel

One of the shiny new extensions shipped with version 1.5.1 is the [History Recording viewer](https://guacamole.apache.org/doc/1.5.1/gug/recording-playback.html) inside Guacamole itself.

But there are some steps required to make it work properly.

First, create a folder that will store the recordings and that must be accessible to Docker. The easiest is to use a sub-folder from the config directory you need to use to start the container. `config/guacamole/recordings` looks like a good option.

Then, you will need to amend the `guacamole.properties` file to override Guacamole's default behaviour. Add the following line: `recording-search-path: /config/guacamole/recordings`

Amend your docker-compose.yml, or your docker run command, to add the history-recording-storage extension (`EXTENSIONS=auth-ldap,auth-duo, history-recording-storage` for example).

Restart the container to load the changes. make sure the extension has been copied in the `/config/guacamole/extensions` directory. If not, I messed something up in the image, and I'll let you report an issue!

Now, you can setup the [session recording as per the Guacamole manual](https://guacamole.apache.org/doc/1.5.1/gug/recording-playback.html#configuring-connections-to-use-recording-storage), and when a connection that has recording enabled is closed, you should be able to see in the recordings directory, and see the "View >" link in the History tab:

![historylog](https://user-images.GitHubusercontent.com/19927690/223395605-639a9938-ac05-4ab0-87cf-a9ef4f299310.PNG)

Recordings can be found in  your Guacamole server:

![recordings](https://user-images.GitHubusercontent.com/19927690/223395285-a8aef74d-00e2-4f3d-af15-92415a101557.png)

Note that guacamole needs to be allowed to read and write into the directory storing the recordings. Please see [this discussion](https://lists.apache.org/thread/6z4rr7jo0cbvf1hf0s6m38kxgnkp7wcf) for a good summary of the requirements.



### Underscore character is not displayed in SSH sessions

There is a known bug, where, in certain conditions, the underscore character is not displayed properly. This issue appeared since Guacamole 1.3, and still exists in 1.4.

Based on some investigations, it seems the issue is with the libpango library (text rendering library), that is used by Guacamole. The issue has been known for quite a few years now by the library team, but unfortunately, it does not look like a solution will ever be found, as it really appears to be quite random and difficult to reproduce.


[![IMAGE ALT TEXT](https://GitHub.com/abesnier/docker-guacamole/raw/master/underscore.png)](https://GitHub.com/abesnier/docker-guacamole/raw/master/underscore.png|width=200px)


Please have a look at this [JIRA issue](https://issues.apache.org/jira/browse/GUACAMOLE-1478?jql=project%20%3D%20GUACAMOLE%20AND%20text%20~%20underscore) for details.


Now, that being said, here's what happens: by default, a new ssh connection will use the default remote machine font (most likely the default monospace font, and in most Linux distros these days, it is DejaVu or Nimbus), with a size 12.

This exact configuration, in some cases will result in the underscore not being displayed.


There are two solutions that worked for me: 

* Change the base image for my Docker image (downgrading from Debian Bullseye to Debian Buster)

* Change the font size in the connection settings


The first solution is not good for me, as the idea of this image is to be kept up-to-date with the latest available packages.


The second solution is easy to implement, but it must be done by the admin. Go to Guacamole > Settings > Connections > Parameters > change the font size to 14 for example > save your changes.


### The container fails to start properly

If the docker seems to not start properly, check the logs with `docker logs <container_name>`. It may be useful to start the container with a higher debug verbosity, by using the GUACD_LOG_LEVEL environment variable. The variable can be set either by adding `-e GUACD_LOG_LEVEL=debug` to your docker run command, or in the environment section of your `docker-compose.yml` file. The log will be more verbose, and will help you pinpoint the errors.


If you see lines like this one: `postgres: could not access the server configuration file "/config/postgres/postgresql.conf": No such file or directory`, this means that the configuration volume could not be mounted properly. 


If that is the case, make sure to start the container as root. This will force the creation of the config folder.

```shell

docker run \

  -p 8080:8080 \

  -u root \

  -v </path/to/config>:/config \

  abesnier/guacamole

```


or in docker-compose.yml:


```yml

version: "3"

services:

  guacamole:

    image: abesnier/guacamole

    container_name: guacamole

    user: root

    volumes:

      - </path/to/config>:/config

    ports:

      - 8080:8080

```

### I have tried a 1.5.1RC1 image, updated to 1.5.1, and the login page still tells me I use version 1.5.1-RC1

Yeah, I know. As Docker still sees a guacamole-brading-1.5.1.jar in the `config/guacamole/extensions` directory, it will not overwrite it with the file in the image.

The solution is simply to remove the jar file in the config directory, and restart the container.


### I forgot my password and have deleted the default guacadmin user, what can I do?

This [issue](https://github.com/abesnier/docker-guacamole/issues/35) was raised on Github, and here are the solutions:

1 - Delete the content of the config directory, and the full setup of Guacamole will be reset. You will lose all your connections, history, etc... but the default user will be re-generated.

2 - Download the database schema for the default user from https://raw.githubusercontent.com/apache/guacamole-client/main/extensions/guacamole-auth-jdbc/modules/guacamole-auth-jdbc-postgresql/schema/002-create-admin-user.sql and put it in your config directory.

Enter the docker container (`docker exec -it guacamole bash`)

Execute the SQL file with command `psql -U guacamole guacamole_db -a -f 002-create-admin-user.sql`.

You can now logon with guacadmin/guacadmin.


### Back up the config folder and start again

Well, I must admit, I managed to break a few things here and there nevertheless...

The easiest way to correct issues is to stop the container, delete the config folder, and restart the container.


But this has the side effect of deleting your stored users and connections as well.


You can backup and restore the database with the following command (assuming your container is named `guacamole`):


Backup: `docker exec -it guacamole bash -c "pg_dump -U guacamole -F t guacamole_db > guacamole_db_backup.tar"`


This creates a `guacamole_db_backup.tar` in your `config` directory that you need to save somewhere else.


Now stop the container, delete the config folder, and restart the container.


To restore the database, copy the backup file in your mounted config folder, and run `docker exec -it guacamole bash -c "pg_restore -d guacamole_db guacamole_db_backup.tar -c -U guacamole"`. You can now login to Guacamole with your user data and should find your connections as you left them.


### Report an issue with the image

Have a look at the [GitHub repo](https://GitHub.com/abesnier/docker-guacamole), and the [Issues](https://GitHub.com/abesnier/docker-guacamole/issues) page.


### Official support pages

If you believe the issue is with Guacamole and not the docker image, have a look at the [mailing list](https://lists.apache.org/list.html?user@guacamole.apache.org) for general support, and if you believe there is a bug, use the [bug tracker](https://issues.apache.org/jira/projects/GUACAMOLE/summary) to report it.


And of course, don't forget to look at the [official documentation](https://guacamole.apache.org/doc/gug).



## License

Copyright (C) 2021-2025 abesnier

Copyright (C) 2017-2020 oznu

Apache Guacamole is released under the Apache License version 2.0.

Extensions uses third-party modules. To consult the licensing for each module, download the extension from https://guacamole.apache.org/releases/1.5.5/, extract it, and check the content of the `bundled` directory.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the [GNU General Public License](./LICENSE) for more details.
