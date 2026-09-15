import QtQuick
import QtQuick.Window
import QtMultimedia

Item {
    readonly property real s: Screen.height / 768
    anchors.fill: parent

    property bool videoReady: false

    MediaPlayer {
        id: mediaplayer

        source: "bg.mp4"
        autoPlay: true
        loops: MediaPlayer.Infinite
        videoOutput: videoOutput

        onPlaybackStateChanged: {
            if (playbackState === MediaPlayer.PlayingState)
                videoReady = true
        }
    }

    VideoOutput {
        id: videoOutput
        anchors.fill: parent
        fillMode: VideoOutput.PreserveAspectCrop
        opacity: videoReady ? 1 : 0

        Behavior on opacity {
            NumberAnimation {
                duration: 1200
                easing.type: Easing.OutCubic
            }
        }
    }
}