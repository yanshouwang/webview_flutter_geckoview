/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

const javascriptChannels = new Map();
const webExtensionPort = browser.runtime.connectNative("webview_flutter");

async function addJavascriptChannel(channelName) {
    try {
        const javascript = `window["${channelName}"] = {
            postMessage: function(message) {
                browser.runtime.sendMessage({
                    type: "javascript_channel_message",
                    channelName: "${channelName}",
                    message: message
                });
            }
        };`;
        const javascriptChannel = await browser.contentScripts.register({
            matches: [
                "<all_urls>"
            ],
            js: [
                { code: javascript }
            ],
            runAt: "document_start"
        });
        const tabs = await browser.tabs.query({});
        for (const tab of tabs) {
            browser.tabs.executeScript(
                tab.id,
                {
                    code: javascript,
                    runAt: "document_start"
                }
            );
        }
        javascriptChannels.set(channelName, javascriptChannel);
        console.info(`addJavascriptChannel: ${channelName}`);
    } catch (error) {
        console.error(`addJavascriptChannel error: ${error}`);
    }
}

async function removeJavascriptChannel(channelName) {
    try {
        const javascriptChannel = javascriptChannels.get(channelName);
        await javascriptChannel.unregister();
        const tabs = await browser.tabs.query({});
        for (const tab of tabs) {
            await browser.tabs.executeScript(
                tab.id,
                {
                    code: `delete window["${channelName}"];`,
                    runAt: "document_start"
                }
            );
        }
        javascriptChannels.delete(channelName);
        console.info(`removeJavascriptChannel: ${channelName}`);
    } catch (error) {
        console.error(`removeJavascriptChannel error: ${error}`);
    }
}

async function evaluateJavascript(javascript) {
    try {
        const result = await browser.tabs.executeScript({
            code: javascript,
            runAt: "document_start"
        });
        console.info(`evaluateJavascript result: ${result}`);
    } catch (error) {
        console.error(`evaluateJavascript error: ${error}`)
    }
}

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

browser.tabs.onUpdated.addListener((tabId, changeInfo) => {
    console.info(`tabs updated: ${tabId}, ${JSON.stringify(changeInfo)}`);
    if (changeInfo.status === "complete") {
        for (const [channelName] of javascriptChannels) {
            const javascript = `window["${channelName}"] = {
                postMessage: function(message) {
                    browser.runtime.sendMessage({
                        type: "javascript_channel_message",
                        channelName: "${channelName}",
                        message: message
                    });
                }
            };`;
            browser.tabs.executeScript(
                tabId,
                {
                    code: javascript,
                    runAt: "document_start"
                }
            );
        }
    }
});

webExtensionPort.onDisconnect.addListener(() => {
    console.info("webExtensionPort disconnected");
});

webExtensionPort.onMessage.addListener(async (message) => {
    console.info(`webExtensionPort message: ${JSON.stringify(message)}`);
    const items = Array.from(javascriptChannels.entries());
    console.info(`registrations: ${JSON.stringify(items)}`);
    if (!message || typeof message.action !== "number") {
        return;
    }
    if (message.action === 0 && typeof message.channelName === "string") {
        await addJavascriptChannel(message.channelName);
    } else if (message.action === 1 && typeof message.channelName === "string") {
        await removeJavascriptChannel(message.channelName);
    } else {
        await evaluateJavascript(message.javascript);
    }
});
