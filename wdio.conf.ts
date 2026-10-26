import 'dotenv/config';
import path from 'node:path';

const app = process.env.APP_PATH;

export const config: WebdriverIO.Config = {
  runner: 'local',
  hostname: '127.0.0.1',
  port: 4723,
  path: '/',
  specs: ['./test/specs/**/*.spec.ts'],
  maxInstances: 1,
  capabilities: [{
    platformName: 'Android',
    'appium:automationName': 'UiAutomator2',
    'appium:deviceName': process.env.DEVICE_NAME || 'Android',
    ...(process.env.DEVICE_UDID ? { 'appium:udid': process.env.DEVICE_UDID } : {}),
    ...(app
      ? { 'appium:app': path.resolve(app) }
      : {
          'appium:appPackage': process.env.APP_PACKAGE || 'com.android.settings',
          'appium:appActivity': process.env.APP_ACTIVITY || '.Settings',
        }),
    'appium:noReset': true,
    'appium:newCommandTimeout': 120,
  }],
  logLevel: 'info',
  waitforTimeout: 10000,
  connectionRetryTimeout: 120000,
  connectionRetryCount: 1,
  services: [['appium', { args: { address: '127.0.0.1', port: 4723 }, logPath: './logs' }]],
  framework: 'mocha',
  reporters: ['spec'],
  mochaOpts: { ui: 'bdd', timeout: 60000 },
};
