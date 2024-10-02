# Roku SDK Automated Testing

Roku channel developers can use Roku's test automation software to write and execute test cases, including channel purchasing, performance, deep linking, and other certification-related testing. Roku provides custom [Selenium](https://selenium.dev)-based [WebDriver APIs](https://developer.roku.com/docs/developer-program/dev-tools/automated-channel-testing/web-driver.md) for sending commands to launch channels, send keypresses, and check whether SceneGraph components are present on the screen. Channels can use the WebDriver APIs to control a Roku device, while using a test framework or programming language to create, run, log, and record test cases. To make automated testing even easier, Roku provides [Robot](https://developer.roku.com/docs/developer-program/dev-tools/automated-channel-testing/robot-framework-library.md) and [JavaScript](https://developer.roku.com/docs/developer-program/dev-tools/automated-channel-testing/javascript-library.md) libraries, which support running tests on multiple devices at the same time.

Executing test automation allows channels to run state-driven UI testing for a number of scenarios. For example, channels can create a test case that installs a channel and launches it with a specific contentID and mediaType to verify that deep linking works. Authenticated channels can execute more complex test cases such as launching a channel, trying to play content before authenticating the user, entering valid/invalid credentials, and then trying to play content again.

All test cases can be run simultaneously on multiple Roku devices. This is useful for testing channel performance across different models with varying RAM and CPU. It is especially important for certification testing, which requires channels to meet [performance criteria](https://developer.roku.com/docs/developer-program/certification/certification.md#3-performance) that varies for different device types.

Implementing automated testing speeds up channel development by reducing the number of manual UI tests that need to be run for simple to complex test cases.

> Roku's test automation tools require Roku OS 9.1 or higher.

> To test production channels with the Roku test automation tools, you must [package the channel](https://developer.roku.com/docs/developer-program/publishing/packaging-channels.md#rekeying) on your Roku device using the same Roku developer account linked to the production version of the channel.

## Getting started

### Installing and testing the Roku JavaScript Library

To install the [Roku JavaScript Library](https://developer.roku.com/docs/developer-program/dev-tools/automated-channel-testing/javascript-library.md) and test it on one or more devices, follow these steps:

1.  Download and install the [node.js](https://nodejs.org/en/) JavaScript runtime environment.

2.  Download and install the [Yarn](https://classic.yarnpkg.com/en/docs/install) JavaScript package manager.

3.  Install the dependencies listed in the **/automated-channel-testing-master/jsLibrary/package.json** file:

        yarn install

4.  To use the [Mocha](https://mochajs.org/) JavaScript test framework and run tests on multiple devices, globally install Mocha and [Mochawesome](https://www.npmjs.com/package/mochawesome):

        yarn global add mocha
        yarn global add mochawesome

5.  Run the setup script to set up the environment variables for the tests.

        ./setup_tests.sh

    OR Update the **/automated-channel-testing-master/jsLibrary/tests/test_basic.js** file with the following:

        a. In line 26, update the IP address to your Roku device.

        b. In line 27, update the password.

6.  Run the make file to build the test app

        make test-app

    this command will copy the SDK and put it in the tests folder as sample/test-app.zip which is used to run the tests

7.  Run the web driver binary file in the bin directory. You should just be able to open it in finder and it will run in terminal.

8.  Run the sample basic JavaScript test case on a single device. When running the JavaScript tests and samples, you must run them from the **jsLibrary** folder

         mocha tests/test_basic.js --reporter mochawesome

9.  View the generated test case report, which is stored in the **mochawesome-report** directory.
