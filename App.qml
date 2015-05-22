import QtQuick 2.3
import QtQuick.Controls 1.2

ApplicationWindow {
	width: 800;
	height: 600;
	visible: true;
	color: 'black';

	GridView {
		id: channelView;
		anchors.fill: parent;
		cellWidth: 80;
		cellHeight: 60;
		model: channelModel;
		delegate: Item {
			width: channelView.cellWidth;
			height: channelView.cellHeight;

			Rectangle {

				color: '#555555';
			}

			Image {
				id: image;
				anchors.fill: parent;
				fillMode: Image.PreserveAspectFit;
				source: cover;
				opacity: 0;

				transitions: [
					Transition {
						NumberAnimation {
							properties: 'opacity';
							duration: 300;
							easing.type: Easing.OutCubic;
						}
					}
				]

				states: [
					State {
						name: 'loaded';
						when: (image.status == Image.Ready)

						PropertyChanges {
							target: image;
							opacity: 1;
						}
					}
				]
			}
		}
/*
		add: Transition {
			NumberAnimation {
				properties: 'opacity';
				from: 0;
				to: 1;
				duration: 1000;
				easing.type: Easing.OutCubic;
			}
		}
*/
	}

	ListModel {
		id: channelModel;
	}

	Timer {
		property int counter: 0;
		property int limit: 50;
		id: fetcher;
		running: false;
		repeat: false;
		interval: 0;
		onTriggered: {
			counter++;
			if (counter < limit) {
				fetchChannels(50 * counter, function() {
					fetcher.running = true;
				});
			}
		}
	}

	function fetchChannels(start, callback) {
		var _start = start || 0;
		var xhr = new XMLHttpRequest;
		xhr.open('GET', 'http://higgstv.com/apis/getchannels?user=composer&start=' + _start);
		xhr.onreadystatechange = function() {
			if (xhr.readyState == XMLHttpRequest.DONE) {
				var data = JSON.parse(xhr.responseText);

				for (var index in data.channels) {
					var channel = data.channels[index];

					var cover = '';
					if (channel.cover)
						cover = channel.cover.default;

					channelModel.append({
						id: channel._id,
						cover: cover,
						name: channel.name
					});
				}

				if (callback)
					callback();
			}
		}
		xhr.send();
	}

	Component.onCompleted: {
		fetcher.running = true;
	}
}
