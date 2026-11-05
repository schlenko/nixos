import QtQuick
import "../../services"
import "../../theme"
import ".."

// Clipboard history. Click an entry to copy it again; Edit opens it in a text
// editor; the cross deletes it.
Item {
    id: root

    // Entry that was just copied, shown with a check mark for a moment.
    property string copiedId: ""

    // Entry open in the editor ("" = none) and what it said when opened.
    property string editingId: ""
    property string original: ""
    property bool editorHolding: false

    // Hidden label, only used to borrow the default text colour and font.
    Label {
        id: probe
        visible: false
    }

    Timer {
        id: copiedReset
        interval: 1200
        onTriggered: root.copiedId = ""
    }

    function startEdit(id) {
        editor.text = "";
        original = "";
        editingId = id;
        // Keeps the island open and gives it the keyboard while typing.
        if (!editorHolding) {
            IslandState.holdOpen();
            editorHolding = true;
        }
        Clipboard.load(id);
    }

    function closeEdit() {
        editingId = "";
        if (editorHolding) {
            IslandState.release();
            editorHolding = false;
        }
    }

    function saveEdit() {
        if (editingId !== "" && editor.text !== original)
            Clipboard.saveEdit(editingId, editor.text);
        closeEdit();
    }

    Component.onDestruction: {
        if (editorHolding)
            IslandState.release();
    }

    Connections {
        target: Clipboard
        function onEditLoaded(id) {
            if (id !== root.editingId)
                return;
            root.original = Clipboard.editText;
            editor.text = Clipboard.editText;
            editor.cursorPosition = editor.length;
            editor.forceActiveFocus();
        }
    }

    Label {
        anchors.left: parent.left
        anchors.leftMargin: 4
        anchors.verticalCenter: clearButton.verticalCenter
        text: Clipboard.items.length + (Clipboard.items.length === 1 ? " item" : " items")
        color: Theme.textTertiary
        font.pixelSize: Theme.fontSmall
        font.weight: Font.Medium
    }
    IslandButton {
        id: clearButton
        anchors.right: parent.right
        anchors.top: parent.top
        visible: Clipboard.items.length > 0
        text: "Clear all"
        fontSize: Theme.fontSmall
        subtle: true
        onClicked: Clipboard.clear()
    }

    Column {
        anchors.centerIn: list
        spacing: 8
        visible: Clipboard.items.length === 0

        Icon {
            anchors.horizontalCenter: parent.horizontalCenter
            name: "copy"
            size: 26
            color: Theme.textTertiary
        }
        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Settings.clipboardEnabled ? "Copied text shows up here" : "Clipboard history is off"
            color: Theme.textSecondary
        }
    }

    ListView {
        id: list
        anchors.top: clearButton.bottom
        anchors.topMargin: 6
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        clip: true
        spacing: 2
        model: Clipboard.items
        boundsBehavior: Flickable.StopAtBounds

        delegate: Rectangle {
            id: entry

            required property var modelData
            readonly property bool copied: root.copiedId === modelData.id
            // Images and other binary entries can't be edited as text.
            readonly property bool editable: !modelData.text.startsWith("[[ binary data")

            width: ListView.view.width
            height: 32
            radius: 10
            color: copied ? Qt.rgba(Theme.green.r, Theme.green.g, Theme.green.b, 0.14)
                : rowHover.hovered ? Theme.surface : "transparent"
            Behavior on color { ColorAnimation { duration: Theme.fadeDuration } }

            // Stays hovered over the buttons too, unlike a MouseArea.
            HoverHandler {
                id: rowHover
            }

            MouseArea {
                id: rowMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    Clipboard.copy(entry.modelData.id);
                    root.copiedId = entry.modelData.id;
                    copiedReset.restart();
                }
            }

            Label {
                anchors.left: parent.left
                anchors.leftMargin: 10
                anchors.right: trailing.left
                anchors.rightMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                text: entry.modelData.text
                font.pixelSize: Theme.fontBody - 1
                elide: Text.ElideRight
            }

            Item {
                id: trailing
                anchors.right: parent.right
                anchors.rightMargin: 4
                anchors.verticalCenter: parent.verticalCenter
                width: 76
                height: 28

                Icon {
                    anchors.right: parent.right
                    anchors.rightMargin: 7
                    anchors.verticalCenter: parent.verticalCenter
                    visible: entry.copied
                    name: "check"
                    size: 15
                    color: Theme.green
                }
                IslandButton {
                    id: editButton
                    anchors.right: deleteButton.left
                    anchors.rightMargin: 2
                    anchors.verticalCenter: parent.verticalCenter
                    visible: !entry.copied && entry.editable
                    opacity: rowHover.hovered ? 1 : 0
                    text: "Edit"
                    fontSize: Theme.fontSmall
                    subtle: true
                    onClicked: root.startEdit(entry.modelData.id)
                    Behavior on opacity { NumberAnimation { duration: Theme.fadeDuration } }
                }
                IslandButton {
                    id: deleteButton
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    visible: !entry.copied
                    opacity: rowHover.hovered ? 1 : 0
                    icon: "close"
                    iconSize: 13
                    color: Theme.textSecondary
                    onClicked: Clipboard.remove(entry.modelData.id)
                    Behavior on opacity { NumberAnimation { duration: Theme.fadeDuration } }
                }
            }
        }
    }

    // The editor covers the whole tab while an entry is being edited.
    Item {
        id: editorPane
        anchors.fill: parent
        visible: root.editingId !== ""
        z: 10

        Rectangle {
            anchors.fill: parent
            color: Theme.island
        }
        // Swallow clicks so nothing underneath reacts.
        MouseArea {
            anchors.fill: parent
        }

        Label {
            anchors.left: parent.left
            anchors.leftMargin: 4
            anchors.verticalCenter: saveButton.verticalCenter
            text: "Editing  ·  Ctrl+Enter to save, Esc to cancel"
            color: Theme.textTertiary
            font.pixelSize: Theme.fontSmall
            font.weight: Font.Medium
        }
        IslandButton {
            id: cancelButton
            anchors.right: saveButton.left
            anchors.rightMargin: 6
            anchors.top: parent.top
            text: "Cancel"
            fontSize: Theme.fontSmall
            subtle: true
            onClicked: root.closeEdit()
        }
        IslandButton {
            id: saveButton
            anchors.right: parent.right
            anchors.top: parent.top
            text: "Save"
            fontSize: Theme.fontSmall
            onClicked: root.saveEdit()
        }

        Rectangle {
            anchors.top: saveButton.bottom
            anchors.topMargin: 6
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            radius: 10
            color: Theme.surface

            Flickable {
                id: flick
                anchors.fill: parent
                anchors.margins: 10
                clip: true
                contentWidth: width
                contentHeight: editor.contentHeight
                boundsBehavior: Flickable.StopAtBounds

                TextEdit {
                    id: editor
                    width: flick.width
                    wrapMode: TextEdit.Wrap
                    selectByMouse: true
                    color: probe.color
                    font.family: probe.font.family
                    font.pixelSize: Theme.fontBody - 1

                    // Keep the cursor in view while typing.
                    onCursorRectangleChanged: {
                        const r = cursorRectangle;
                        if (flick.contentY >= r.y)
                            flick.contentY = r.y;
                        else if (flick.contentY + flick.height <= r.y + r.height)
                            flick.contentY = r.y + r.height - flick.height;
                    }

                    Keys.onEscapePressed: root.closeEdit()
                    Keys.onPressed: event => {
                        if ((event.key === Qt.Key_Return || event.key === Qt.Key_Enter)
                                && (event.modifiers & Qt.ControlModifier)) {
                            root.saveEdit();
                            event.accepted = true;
                        }
                    }
                }
            }
        }
    }
}