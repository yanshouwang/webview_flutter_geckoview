/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

const javascriptChannels = new Map();
const webExtensionPort = browser.runtime.connectNative("webview_flutter");

webExtensionPort.onDisconnect.addListener(() => {
    console.info("webExtensionPort disconnected");
});

webExtensionPort.onMessage.addListener(async (command) => {
    console.info(`webExtensionPort received: ${JSON.stringify(command)}`);
    if (!command) {
        return;
    }
    const type = command.type;
    const id = command.id;
    if (typeof type !== "number" || typeof id !== "number") {
        return;
    }
    let reply = {
        type: type,
        id: id,
    };
    try {
        switch (type) {
            case 0: {
                const javascriptChannelName = command.name;
                await addJavascriptChannel(javascriptChannelName);
                break;
            }
            case 1: {
                const javascriptChannelName = command.name;
                await removeJavascriptChannel(javascriptChannelName);
                break;
            }
            case 2: {
                const javascript = command.javascript;
                reply.result = await runJavascript(javascript);
                break;
            }
            default: {
                throw new TypeError(`illegal type: ${type}`);
            }
        }
    } catch (error) {
        reply.error = error.toString();
    } finally {
        webExtensionPort.postMessage(reply);
    }
});

browser.runtime.onMessage.addListener((event) => {
    if (!event) {
        return;
    }
    webExtensionPort.postMessage(event);
});

async function addJavascriptChannel(javascriptChannelName) {
    const javascript = `
        window["${javascriptChannelName}"] = {
            postMessage: function(message) {
                browser.runtime.sendMessage({
                    type: 3,
                    name: "${javascriptChannelName}",
                    message: message
                });
            }
        };
    `;
    const tabs = await browser.tabs.query({});
    for (const tab of tabs) {
        await browser.tabs.executeScript(
            tab.id,
            {
                code: javascript,
                runAt: "document_start"
            }
        );
    }
    const javascriptChannel = await browser.contentScripts.register({
        matches: [
            "<all_urls>"
        ],
        js: [
            {
                code: javascript
            }
        ],
        runAt: "document_start"
    });
    javascriptChannels.set(javascriptChannelName, javascriptChannel);
}

async function removeJavascriptChannel(javascriptChannelName) {
    const javascriptChannel = javascriptChannels.get(javascriptChannelName);
    await javascriptChannel.unregister();
    const javascript = `delete window["${javascriptChannelName}"];`;
    const tabs = await browser.tabs.query({});
    for (const tab of tabs) {
        await browser.tabs.executeScript(
            tab.id,
            {
                code: javascript,
                runAt: "document_start"
            }
        );
    }
    javascriptChannels.delete(javascriptChannelName);
}

async function runJavascript(javascript) {
    const result = await browser.tabs.executeScript(
        {
            code: javascript,
            runAt: "document_start"
        }
    );
    return result.firstOrNull;
}
