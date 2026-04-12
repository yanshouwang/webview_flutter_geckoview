/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

// Establish connection with app
const port = browser.runtime.connectNative("browser");
port.onMessage.addListener(message => {
  switch (message.action) {
    case 0: // Add javascript channel
      browser.tabs.executeScript({
        code: `window.${message.channelName} = { postMessage: function(message) {
          browser.runtime.sendMessage({ channelName: '${message.channelName}', message: String(message) });
        }};`
      });
      break;
    case 1: // Remove javascript channel
      break;
    case 2: // Run javascript
      browser.tabs.executeScript({ code: message.javascript });
      break;
    default:
      break;
  }
});
browser.runtime.onMessage.addListener(message => {
  if (message.channelName) {
    port.postMessage(message);
  }
});
