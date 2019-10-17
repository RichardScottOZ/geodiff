#!/usr/bin/env bash

set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
PWD=`pwd`

echo -n "Publishing pygeodiff to $URL"
cd $DIR/../..

$DIR/clean.bash

# publish sdist
if [ "$TRAVIS_OS_NAME" == "linux" ]; then
   python3 setup.py sdist
   ${PYTHON} -m twine upload  dist/* --username "__token__" --password "$PYPI_TOKEN"  --skip-existing
fi

$DIR/clean.bash

# publish wheels
if [ "$TRAVIS_OS_NAME" == "linux" ]; then
   PYTHON=python3
   PLAT=manylinux2010_x86_64
   DOCKER_IMAGE=quay.io/pypa/manylinux2010_x86_64
   docker run --rm -e PLAT=$PLAT -v $DIR/../../:/io $DOCKER_IMAGE /io/scripts/ci/linux/build_wheel.bash
elif [ "$TRAVIS_OS_NAME" == "windows" ]; then
   PYTHON=C:/Python38/python.exe
   $DIR/windows/build_wheel.bash
else
   # MacOS
   PYTHON=python3
   $DIR/osx/build_wheel.bash
fi

${PYTHON} -m twine upload  dist/* --username "__token__" --password "$PYPI_TOKEN"  --skip-existing

cd $PWD