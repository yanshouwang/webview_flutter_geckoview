/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

const BRIDGE_EVENT = "__gv_bridge__";
const webExtensionPort = browser.runtime.connectNative("webview_flutter");

function addJavascriptChannel(channelName) {
	const safeChannelName = JSON.stringify(channelName);
	const safeBridgeEvent = JSON.stringify(BRIDGE_EVENT);

	runJavascript(`
		window[${safeChannelName}] = {
			postMessage: function(message) {
				window.dispatchEvent(new CustomEvent(${safeBridgeEvent}, {
					detail: {
						channelName: ${safeChannelName},
						message: String(message)
					}
				}));
			}
		};
	`);
}

function removeJavascriptChannel(channelName) {
	const safeChannelName = JSON.stringify(channelName);
	runJavascript(`
		try {
			delete window[${safeChannelName}];
		} catch (_) {}
	`);
}

function runJavascript(text) {
	const script = document.createElement("script");
	script.textContent = text;
	(document.documentElement || document.head).appendChild(script);
	script.remove();
}

window.addEventListener(BRIDGE_EVENT, event => {
	const detail = event && event.detail;
	if (!detail || !detail.channelName) {
		return;
	}

	webExtensionPort.postMessage({
		channelName: detail.channelName,
		message: detail.message,
	});
});

webExtensionPort.onDisconnect.addListener(() => {
	console.warn("Disconnected from native messaging port");
});

webExtensionPort.onMessage.addListener(message => {
	if (!message || typeof message.action !== "number") {
		return;
	}

	switch (message.action) {
		case 0: // Add javascript channel
			if (typeof message.channelName === "string" && message.channelName.length > 0) {
				addJavascriptChannel(message.channelName);
			}
			break;
		case 1: // Remove javascript channel
			if (typeof message.channelName === "string" && message.channelName.length > 0) {
				removeJavascriptChannel(message.channelName);
			}
			break;
		case 2: // Run javascript
			runJavascript(String(message.javascript || ""));
			break;
		default:
			break;
	}
});
