/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

const registrations = new Map();
const webExtensionPort = browser.runtime.connectNative("webview_flutter");

browser.runtime.onMessage.addListener((message) => {
    console.info(`browser message: ${JSON.stringify(message)}`);
    if (!message || message.type !== "javascript_channel_message") {
        return;
    }
    if (typeof message.channelName !== "string") {
        return;
    }
    webExtensionPort.postMessage(
        JSON.stringify({
            channelName: message.channelName,
            message: String(message.message ?? ""),
        })
    );
});

webExtensionPort.onDisconnect.addListener(() => {
    console.info("webExtensionPort disconnected");
});

webExtensionPort.onMessage.addListener(async (message) => {
    console.info(`webExtensionPort message: ${JSON.stringify(message)}`);
    if (!message || typeof message.action !== "number") {
        return;
    }
    if (message.action === 0 && typeof message.channelName === "string") {
        const registration = await browser.contentScripts.register({
            matches: ["<all_urls>"],
            js: [
                {
                    code: `window[${message.channelName}] = {
                        postMessage: function(message) {
                            browser.runtime.sendMessage({
                                type: "javascript_channel_message",
                                channelName: channelName,
                                message: String(message)
                            });
                        }
                    };`
                }
            ],
            runAt: "document_start"
        });
        registrations.set(message.channelName, registration);
    } else if (message.action === 1 && typeof message.channelName === "string") {
        const registration = registrations.get(message.channelName);
        if (registration) {
            await registration.unregister();
            registrations.delete(message.channelName);
        }
    } else {
        browser.tabs.executeScript({
            code: message.javascript
        });
    }
});
