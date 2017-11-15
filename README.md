# android-ugbs-docker

Android Universal Build ( including Gradle / SDK / NDK etc) Toolchains shipped via Docker

# Tools Infos

* OpenJDK 1.8
* Gradle 3.4.1
* CMake 3.9.6
* Android SDK 25.2.3
* Android NDK r13b

# Usage

* build image

clone this project and build
```bash
docker build quanken/android-ugbs-docker .
```

* work with projects

just run `compile.sh` in your project root dir
```bash
$ cd /path/to/your/project
# here `gradle build` is the build command
$ ./compile.sh gradle build
```

or run the whole raw script in the `compile.sh`

```
# here `gradle build` is the build command
$ docker run --tty --interactive --volume=$(pwd):/opt/workspace --user `id -F` --workdir=/opt/workspace --rm quanken/android-ugbs-docker /bin/sh -c "gradle build"
```
