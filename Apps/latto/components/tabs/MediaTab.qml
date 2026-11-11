
import QtQuick
import Quickshell
import Quickshell.Io
import "../../services"
import "../../theme"
import ".."

// Now playing: artwork, title and live lyrics, a seek bar and transport controls.
Item {
    id: root

    readonly property bool hasPlayer: Media.player !== null
    readonly property string nextLyric: Lyrics.currentIndex + 1 < Lyrics.lines.length
        ? Lyrics.lines[Lyrics.currentIndex + 1].text : ""

    // Cava visualizer data
    property int cavaBars: 32
    property int cavaSpacing: 2
    property int cavaWaveLength: 10
    property real cavaWavePosition: -10
    property var cavaLevels: []

    // Bass-reactive shake
    property real shakeX: 0
    property real shakeY: 0
    property real shakeAmount: 8
    property real previousBass: 0
    property real bassThreshold: 2.5
    property int lastShakeTime: 0
    property int shakeCooldown: 100

    // Particle system
    property real averageLoudness: 0
    property var particles: []

    // Restart the wave every time the player shakes.
    function flashCavaBars() {
        cavaWaveAnimation.stop()

        cavaWavePosition = -cavaWaveLength

        cavaWaveAnimation.from = -cavaWaveLength
        cavaWaveAnimation.to = cavaBars
        cavaWaveAnimation.duration = 700
        cavaWaveAnimation.start()
    }

    function detectBass(levels) {
        if (levels.length < 4)
            return

        let total = 0

        for (let level of levels)
            total += level || 0

        let average = total / levels.length
        root.averageLoudness = average

        let bass = 0

        for (let i = 0; i < 4; i++)
            bass += levels[i] || 0

        bass /= 4

        let rise = bass - previousBass
        let now = Date.now()

        if (
            bass > 5 &&
            rise > bassThreshold &&
            now - lastShakeTime > shakeCooldown
        ) {
            shakeAmount = Math.min(4, 1.2 + rise * 0.2)
            lastShakeTime = now

            // All three effects start from the same bass hit.
            shakeAnimation.restart()
            flashCavaBars()
            root.spawnParticles(average)
        }

        previousBass = bass
    }

    function spawnParticles(loudness) {
        let intensity = Math.max(0, Math.min(1, loudness / 100))
        let count = Math.round(5 + intensity * 15)

        let available = Math.max(0, 100 - particles.length)
        count = Math.min(count, available)

        if (count <= 0)
            return

        let next = particles.slice()

        for (let i = 0; i < count; i++) {
            let life = 0.7 + Math.random() * 0.8
            let angle = Math.PI + Math.random() * Math.PI
            let speed = 0.8 + Math.random() * 3.0 + intensity

            next.push({
                x: Math.random() * particleCanvas.width,
                y: particleCanvas.height - 1,

                vx: Math.cos(angle) * speed,
                vy: Math.sin(angle) * speed,

                age: 0,
                wiggleSpeed: 0.03 + Math.random() * 0.06,
                wiggleAmount: 0.3 + Math.random() * 0.8,
                wiggleOffset: Math.random() * Math.PI * 2,

                life: life,
                maxLife: life,
                size: 0.5 + Math.random() * 0.8,
                color: Math.random() > 0.5 ? "#FFFFFF" : "#C4A7E7"
            })
        }

        particles = next
        particleCanvas.requestPaint()
    }

    function updateParticles() {
        let next = []

        for (let p of particles) {
            p.age += 1

            p.vx += (Math.random() - 0.5) * 0.12
            p.vx = Math.max(-2.5, Math.min(2.5, p.vx))

            let sway = Math.sin(
                p.age * p.wiggleSpeed + p.wiggleOffset
            ) * p.wiggleAmount

            p.x += p.vx + sway
            p.y += p.vy
            p.vy += 0.012

            p.life -= 0.016

            if (
                p.life > 0 &&
                p.y > -5 &&
                p.x > -5 &&
                p.x < particleCanvas.width + 5
            ) {
                next.push(p)
            }
        }

        particles = next
        particleCanvas.requestPaint()
    }

    // Particle update timer
    Timer {
        interval: 24
        repeat: true
        running: root.hasPlayer && root.particles.length > 0
        onTriggered: root.updateParticles()
    }

    // Cava process
    Process {
        running: true
        command: [
            "cava", "-p",
            Quickshell.env("HOME") + "/.config/cava/quickshell.conf"
        ]

        stdout: SplitParser {
            onRead: data => {
                let levels = data.split(";")
                    .filter(s => s.length > 0)
                    .map(Number)

                root.cavaLevels = levels
                root.detectBass(levels)
            }
        }
    }

    // Shake animation
    SequentialAnimation {
        id: shakeAnimation

        ParallelAnimation {
            NumberAnimation {
                target: root
                property: "shakeX"
                to: root.shakeAmount
                duration: 25
                easing.type: Easing.OutQuad
            }
            NumberAnimation {
                target: root
                property: "shakeY"
                to: -root.shakeAmount * 0.6
                duration: 25
                easing.type: Easing.OutQuad
            }
        }

        ParallelAnimation {
            NumberAnimation {
                target: root
                property: "shakeX"
                to: -root.shakeAmount * 0.7
                duration: 30
            }
            NumberAnimation {
                target: root
                property: "shakeY"
                to: root.shakeAmount * 0.5
                duration: 30
            }
        }

        ParallelAnimation {
            NumberAnimation {
                target: root
                property: "shakeX"
                to: root.shakeAmount * 0.2
                duration: 25
            }
            NumberAnimation {
                target: root
                property: "shakeY"
                to: -root.shakeAmount * 0.15
                duration: 25
            }
        }

        ParallelAnimation {
            NumberAnimation {
                target: root
                property: "shakeX"
                to: 0
                duration: 65
                easing.type: Easing.OutQuad
            }
            NumberAnimation {
                target: root
                property: "shakeY"
                to: 0
                duration: 65
                easing.type: Easing.OutQuad
            }
        }
    }

    // Cava wave animation
    NumberAnimation {
        id: cavaWaveAnimation
        target: root
        property: "cavaWavePosition"
        duration: 700
        easing.type: Easing.Linear
    }

    // Empty state
    Column {
        anchors.centerIn: parent
        spacing: 10
        visible: !root.hasPlayer

        Icon {
            anchors.horizontalCenter: parent.horizontalCenter
            name: "music"
            size: 30
            color: Theme.textTertiary
        }

        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Nothing playing"
            color: Theme.textSecondary
            font.weight: Font.Medium
        }
    }

    // Player content
    Item {
        anchors.fill: parent
        visible: root.hasPlayer

        transform: Translate {
            x: root.shakeX
            y: root.shakeY / 2
        }

        // Particles render behind the Cava bars.
        Canvas {
            id: particleCanvas
            z: -1
            anchors.fill: parent

            onPaint: {
                let ctx = getContext("2d")
                ctx.clearRect(0, 0, width, height)

                let barWidth = (
                    width - (root.cavaBars - 1) * root.cavaSpacing
                ) / root.cavaBars

                for (let p of root.particles) {
                    let tailX = p.x - p.vx * 2
                    let tailY = p.y - p.vy * 2

                    let left = Math.min(p.x, tailX) - p.size
                    let right = Math.max(p.x, tailX) + p.size
                    let top = Math.min(p.y, tailY) - p.size
                    let bottom = Math.max(p.y, tailY) + p.size

                    let hiddenByBar = false

                    for (let i = 0; i < root.cavaBars; i++) {
                        let barX = i * (barWidth + root.cavaSpacing)

                        let barHeight = Math.max(
                            1,
                            ((root.cavaLevels[i] || 0) / 100) * height
                        )

                        let barY = height - barHeight

                        if (
                            right >= barX &&
                            left <= barX + barWidth &&
                            bottom >= barY &&
                            top <= height
                        ) {
                            hiddenByBar = true
                            break
                        }
                    }

                    if (hiddenByBar)
                        continue

                    let opacity = Math.max(0, p.life / p.maxLife)

                    ctx.globalAlpha = opacity
                    ctx.fillStyle = p.color
                    ctx.beginPath()
                    ctx.arc(p.x, p.y, p.size, 0, Math.PI * 2)
                    ctx.fill()

                    ctx.globalAlpha = opacity * 0.55
                    ctx.strokeStyle = p.color
                    ctx.lineWidth = Math.max(0.6, p.size * 0.55)
                    ctx.beginPath()
                    ctx.moveTo(p.x, p.y)
                    ctx.lineTo(tailX, tailY)
                    ctx.stroke()
                }

                ctx.globalAlpha = 1
            }
        }

        // Cava bars
        Row {
            anchors.fill: parent
            spacing: root.cavaSpacing

            Repeater {
                model: root.cavaBars

                Item {
                    width: (
                        root.width -
                        root.cavaSpacing * (root.cavaBars - 1)
                    ) / root.cavaBars

                    height: root.height

                    Rectangle {
                        width: parent.width
                        height: Math.max(
                            1,
                            ((root.cavaLevels[index] || 0) / 100) * parent.height
                        )

                        anchors.bottom: parent.bottom
                        radius: 2
                        color: Theme.accent

                        // Ten-bar gradient travelling left to right.
                        opacity: {
                            let distance = index - root.cavaWavePosition

                            if (distance < 0 || distance >= root.cavaWaveLength)
                                return 0.2

                        return 0.65 - (1 - distance / (root.cavaWaveLength - 1)) * 0.45
                        }

                        Behavior on height {
                            NumberAnimation {
                                duration: 80
                            }
                        }
                    }
                }
            }
        }

        // Artwork
        RoundedImage {
            id: art
            width: 96
            height: 96
            radius: 16
            source: Media.art
        }

        // Track information and lyrics
        Column {
            anchors.left: art.right
            anchors.leftMargin: 16
            anchors.right: parent.right
            anchors.top: art.top
            anchors.topMargin: 4
            spacing: 3

            Label {
                width: parent.width
                text: Media.title
                font.pixelSize: Theme.fontTitle
                font.weight: Font.ExtraBold
                elide: Text.ElideRight
            }

            Label {
                width: parent.width
                text: Media.artist || Media.source
                color: Theme.textSecondary
                font.pixelSize: Theme.fontSmall + 1
                elide: Text.ElideRight
            }

            Item {
                width: 1
                height: 8
            }

            Label {
                id: lyric
                width: parent.width
                visible: Settings.showLyrics && text !== ""
                text: Lyrics.currentText
                color: Theme.accent
                font.pixelSize: Theme.fontBody
                font.weight: Font.Medium
                wrapMode: Text.Wrap
                maximumLineCount: 2
                elide: Text.ElideRight

                property real blur: 0
                layer.enabled: blur > 0.01
                layer.effect: BlurEffect {
                    amount: lyric.blur
                }

                onTextChanged: lyricIn.restart()

                ParallelAnimation {
                    id: lyricIn

                    NumberAnimation {
                        target: lyric
                        property: "blur"
                        from: Theme.swapBlur
                        to: 0
                        duration: Theme.swapDuration
                        easing.type: Easing.BezierSpline
                        easing.bezierCurve: Theme.smoothCurve
                    }
                }
            }

            Label {
                width: parent.width
                visible: lyric.visible && text !== ""
                text: root.nextLyric
                color: Theme.textTertiary
                font.pixelSize: Theme.fontSmall
                elide: Text.ElideRight
            }
        }

        // Progress / seek bar
        Item {
            id: progressRow
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: art.bottom
            anchors.topMargin: 14
            height: 16

            Label {
                id: elapsed
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                width: 44
                text: Timers.formatTime(Media.position * 1000, false)
                color: Theme.textSecondary
                font.pixelSize: Theme.fontCaption + 1
            }

            Label {
                id: remaining
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                width: 44
                horizontalAlignment: Text.AlignRight
                text: Media.length > 0
                    ? "-" + Timers.formatTime((Media.length - Media.position) * 1000, false)
                    : ""
                color: Theme.textSecondary
                font.pixelSize: Theme.fontCaption + 1
            }

            IslandBar {
                anchors.left: elapsed.right
                anchors.right: remaining.left
                anchors.verticalCenter: parent.verticalCenter
                implicitHeight: seekArea.containsMouse ? 8 : 5
                value: Media.progress
            }

            MouseArea {
                id: seekArea
                anchors.left: elapsed.right
                anchors.right: remaining.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onPressed: mouse => Media.seek(mouse.x / width)

                onPositionChanged: mouse => {
                    if (pressed)
                        Media.seek(mouse.x / width)
                }
            }
        }

        // Transport controls
        Item {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: progressRow.bottom
            anchors.bottom: parent.bottom

            IslandButton {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                visible: Media.shuffleSupported
                icon: "shuffle"
                iconSize: 16
                color: Media.shuffle ? Theme.accent : Theme.textSecondary
                onClicked: Media.toggleShuffle()
            }

            Row {
                anchors.centerIn: parent
                spacing: 14

                IslandButton {
                    anchors.verticalCenter: parent.verticalCenter
                    icon: "previous"
                    iconSize: 22
                    onClicked: Media.previous()
                }

                IslandButton {
                    anchors.verticalCenter: parent.verticalCenter
                    primary: true
                    icon: Media.playing ? "pause" : "play"
                    iconSize: 22
                    onClicked: Media.toggle()
                }

                IslandButton {
                    anchors.verticalCenter: parent.verticalCenter
                    icon: "next"
                    iconSize: 22
                    onClicked: Media.next()
                }
            }

            Label {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                width: 110
                horizontalAlignment: Text.AlignRight
                text: Media.source
                color: Theme.textTertiary
                font.pixelSize: Theme.fontCaption + 1
                elide: Text.ElideRight
            }
        }
    }
}
