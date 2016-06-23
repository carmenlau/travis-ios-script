#!/bin/sh
if [[ "$TRAVIS_PULL_REQUEST" != "false" ]]; then
    echo "This is a pull request. Just build in DEBUG configuration."
    xcodebuild -workspace $WORKSPACE_NAME.xcworkspace \
    -scheme $SCHEME_NAME -sdk $BUILD_SDK \
    -configuration Debug ONLY_ACTIVE_ARCH=NO | xcpretty -c && exit ${PIPESTATUS[0]}
    if [[ $? -ne 0 ]]; then
        echo "Error: Build fail."
        exit 1
    fi

else
    echo "Building..."
    xcodebuild -workspace $WORKSPACE_NAME.xcworkspace \
    -scheme $SCHEME_NAME -sdk $BUILD_SDK ONLY_ACTIVE_ARCH=NO | xcpretty -c && exit ${PIPESTATUS[0]}
    if [[ $? -ne 0 ]]; then
        echo "Error: Build fail."
        exit 1
    fi

    echo "Running test..."
    xcodebuild test -workspace $WORKSPACE_NAME.xcworkspace \
    -scheme $SCHEME_NAME -sdk $BUILD_SDK ONLY_ACTIVE_ARCH=NO | xcpretty -c && exit ${PIPESTATUS[0]}
    if [[ $? -ne 0 ]]; then
        echo "Error: Test fail."
        exit 1
    fi

    echo "Making archive..."
    xcodebuild -workspace $WORKSPACE_NAME.xcworkspace -scheme $SCHEME_NAME \
    -sdk $RELEASE_BUILD_SDK -configuration Release ONLY_ACTIVE_ARCH=NO \
    archive -archivePath $PWD/build/$APP_NAME.xcarchive | xcpretty -c && exit ${PIPESTATUS[0]}
    if [[ $? -ne 0 ]]; then
        echo "Error: Archive fail."
        exit 1
    fi
fi
