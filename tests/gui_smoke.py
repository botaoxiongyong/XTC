"""Project-first GUI integration: full matrix, shared edits, mouse controls and saving."""
import os
os.environ.setdefault('QT_QPA_PLATFORM','offscreen')
import sys
import tempfile
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parents[1]))
from PySide6.QtWidgets import QApplication, QMenu, QPushButton
from PySide6.QtCore import Qt,QPoint,QPointF
from PySide6.QtGui import QContextMenuEvent, QWheelEvent
from PySide6.QtTest import QTest
from app import Window
from workspace import Workspace
from yrr import YRange

app = QApplication([])

# Deterministic synthetic project tests actual click and drag operations without dense real tie markers.
with tempfile.TemporaryDirectory() as directory:
    folder=Path(directory)
    (folder/'test.xtci').write_text('NDS 2 NPC 2\nCP One \\\nCP Two \\\nFR ref.dat\nFR ref.dat\nGC ties.dat\nFP source.dat\nFP source.dat\n')
    (folder/'ref.dat').write_text('0 0\n25 1\n50 0\n75 1\n100 0\n')
    (folder/'source.dat').write_text('0 1\n25 2\n50 1\n75 3\n100 1\n')
    (folder/'ties.dat').write_text('0 0 1\n50 50 0\n100 100 1\n')
    editor=Window(); editor.show(); editor.load_path(folder/'test.xtci'); editor.edit_mode.setChecked(True); app.processEvents()
    band=editor.plot.band(1)
    start=QPoint(round(editor.plot.px(50)),round(band.center().y()))
    end=QPoint(round(editor.plot.px(60)),round(band.center().y()))
    QTest.mousePress(editor.plot,Qt.MouseButton.LeftButton,pos=start)
    QTest.mouseMove(editor.plot,end)
    QTest.mouseRelease(editor.plot,Qt.MouseButton.LeftButton,pos=end)
    assert abs(editor.current_ties()[1][1]-60)<.3
    editor.step(1); assert abs(editor.current_ties()[1][1]-60)<.3
    editor.undo(); assert editor.current_ties()[1][1]==50
    # Pick a source in its band, then the reference position to add a knot.
    QTest.mouseClick(editor.plot,Qt.MouseButton.LeftButton,pos=QPoint(round(editor.plot.px(25)),round(band.center().y())))
    ref=editor.plot.band(0)
    QTest.mouseClick(editor.plot,Qt.MouseButton.LeftButton,pos=QPoint(round(editor.plot.px(30)),round(ref.center().y())))
    assert len(editor.current_ties())==4
    editor.undo(); assert len(editor.current_ties())==3
    def click_button(label):
        next(button for button in editor.findChildren(QPushButton) if button.text() == label).click()

    click_button('Switch to View Mode')
    assert not editor.edit_mode.isChecked() and editor.dock.isHidden()
    click_button('Deselect All')
    assert [row for row, _, _ in editor.plot.items()] == [0]
    click_button('Select All')
    assert [row for row, _, _ in editor.plot.items()] == [0, 1]
    click_button('Switch to Edit Mode')
    assert editor.edit_mode.isChecked() and not editor.dock.isHidden()
    app.processEvents()

    def scroll(delta, modifiers):
        pos = editor.plot.rect_plot().center()
        event = QWheelEvent(pos, QPointF(editor.plot.mapToGlobal(pos.toPoint())), QPoint(),
                            QPoint(0, delta), Qt.MouseButton.NoButton, modifiers,
                            Qt.ScrollPhase.NoScrollPhase, False)
        QApplication.sendEvent(editor.plot, event)

    for editing in (False, True):
        editor.edit_mode.setChecked(editing)
        app.processEvents()
        horizontal = editor.plot.bounds()
        scroll(1200, Qt.KeyboardModifier.ControlModifier)
        assert editor.plot.vertical_overlap == 1
        assert editor.plot.band(0) == editor.plot.band(1) == editor.plot.rect_plot()
        assert editor.plot.bounds() == horizontal
        scroll(120, Qt.KeyboardModifier.ControlModifier)
        assert editor.plot.vertical_overlap == 1
        scroll(-1200, Qt.KeyboardModifier.ControlModifier)
        assert editor.plot.vertical_overlap == 0
        assert editor.plot.band(0).bottom() == editor.plot.band(1).top()
        scroll(30, Qt.KeyboardModifier.NoModifier)
        lo, hi = editor.plot.bounds()
        assert abs((hi - lo) / (horizontal[1] - horizontal[0]) - .88 ** .25) < 1e-9
        assert editor.plot.vertical_overlap == 0
        editor.plot.reset()

    def choose_context_action(x, row, label, enabled=True):
        pos = QPoint(round(editor.plot.px(x)), round(editor.plot.band(row).center().y()))
        event = QContextMenuEvent(QContextMenuEvent.Reason.Mouse, pos, editor.plot.mapToGlobal(pos))
        QApplication.sendEvent(editor.plot, event)
        menu = QApplication.activePopupWidget()
        assert isinstance(menu, QMenu), label
        action = next(action for action in menu.actions() if action.text() == label)
        assert action.isEnabled() == enabled
        if enabled:
            action.trigger()
        menu.close()

    choose_context_action(0, 1, 'Remove age tie point (protected)', enabled=False)
    assert len(editor.current_ties()) == 3
    choose_context_action(25, 1, 'Add age tie point here')
    assert len(editor.current_ties()) == 4 and editor.table.rowCount() == 4 and editor.dirty
    assert editor.plot.pending is None
    added = editor.current_ties()[1]
    band = editor.plot.band(1)
    start = QPoint(round(editor.plot.px(added[1])), round(band.center().y()))
    end = QPoint(round(editor.plot.px(30)), round(band.center().y()))
    QTest.mousePress(editor.plot, Qt.MouseButton.LeftButton, pos=start)
    QTest.mouseMove(editor.plot, end)
    QTest.mouseRelease(editor.plot, Qt.MouseButton.LeftButton, pos=end)
    assert editor.current_ties()[1][0] == added[0]
    assert abs(editor.current_ties()[1][1] - 30) < .3
    with tempfile.TemporaryDirectory() as destination:
        saved = editor.document.export(Path(destination)/'edited.xtci')
        assert Workspace.load(saved).models == editor.document.models
    choose_context_action(30, 1, 'Remove age tie point')
    assert len(editor.current_ties()) == 3
    editor.undo()
    assert len(editor.current_ties()) == 4
    editor.parameters.setCurrentIndex(0)
    editor.y_min.setText('0.5')
    editor.y_max.setText('4')
    editor.y_scale.setCurrentIndex(1)
    editor.y_apply.click()
    styles = folder/'test.xtci.yrr'
    assert styles.is_file()
    assert editor.y_settings[0, 1] == YRange(.5, 4, True)
    saved_lines = styles.read_text().splitlines()
    assert saved_lines[2].startswith('G - ')
    assert Workspace.load(folder/'test.xtci').style_settings[0, 1] == YRange(.5, 4, True)
    # Preserve other parameter rows and the existing inversion on a subsequent edit.
    saved_lines[2] = saved_lines[2].replace('G - ', 'G I ', 1)
    styles.write_text('\n'.join(saved_lines) + '\n')
    editor.load_path(folder/'test.xtci')
    assert editor.y_settings[0, 1].inverted
    editor.y_min.clear()
    editor.y_apply.click()
    assert Workspace.load(folder/'test.xtci').style_settings[0, 1] == YRange(None, 4, True, True)
    assert styles.read_text().splitlines()[3:] == saved_lines[3:]
    editor.y_min.setText('0.5')
    editor.y_apply.click()
    app.processEvents()
    editor.step(1)
    assert editor.y_min.text() == '' and editor.y_scale.currentIndex() == 0
    editor.step(-1)
    assert editor.y_min.text() == '0.5' and editor.y_scale.currentIndex() == 1
    editor.records.setCurrentRow(0)
    editor.y_scale.setCurrentIndex(1)
    editor.y_apply.click()
    assert editor.y_scale.currentIndex() == 0
    assert 'requires positive' in editor.statusBar().currentMessage()
    editor.records.setCurrentRow(1)
    editor.commit_ties(editor.current_ties() + [[25, 30, 0]])
    filenames = {file.name for file in folder.iterdir()}
    dependencies = {file.name: file.read_bytes() for file in folder.iterdir()
                    if file.name != 'ties.dat'}
    assert editor.save()
    assert not editor.dirty
    assert {file.name for file in folder.iterdir()} == filenames
    assert all((folder/name).read_bytes() == data for name, data in dependencies.items())
    reopened = Workspace.load(folder/'test.xtci')
    assert reopened.models == editor.document.models
    assert reopened.style_settings == editor.y_settings
    assert [float(value) for value in (folder/'ties.dat').read_text().splitlines()[1].split()] == [25, 30, 0]
    # Migrate any overrides left by the earlier project-comment save format.
    project_path = folder/'test.xtci'
    original_project = project_path.read_bytes()
    project_path.write_bytes(original_project + b'# XTC-Python model 0\n# XTC-Python tie [0, [0, 0, 1]]\n# XTC-Python tie [0, [100, 100, 1]]\n')
    migrated = Workspace.load(project_path)
    assert migrated.save() == 1
    assert project_path.read_bytes() == original_project
    assert Workspace.load(project_path).models == [[[0, 0, 1], [100, 100, 1]]]
    # Restore the editor's fixture on disk after exercising the older file format.
    (folder/'ties.dat').write_bytes(editor.document.files['ties.dat'])
    assert editor.table.horizontalHeaderItem(2).text() == 'Refer age'
    editor.table.selectRow(1)
    app.processEvents()
    band = editor.plot.band(1)
    x = round(editor.plot.px(editor.current_ties()[1][1]))
    y = round(editor.plot.band(0).center().y())
    selected_plot = editor.plot.grab().toImage()
    ratio = selected_plot.devicePixelRatio()
    pixel = selected_plot.pixelColor(round(x * ratio), round(y * ratio))
    assert pixel.red() > 180 and pixel.green() < 155 and pixel.blue() < 70, pixel.name()
    # The selected line extends through the reference band above the source.
    assert editor.plot.tie_at(QPointF(x, y)) == 1
    editor.tie_table_menu(editor.table.visualItemRect(editor.table.item(1, 0)).center())
    menu = QApplication.activePopupWidget()
    assert isinstance(menu, QMenu)
    assert menu.actions()[0].text() == 'Remove tie points' and menu.actions()[0].isEnabled()
    menu.actions()[0].trigger()
    menu.close()
    assert len(editor.current_ties()) == 3
    editor.undo()
    assert len(editor.current_ties()) == 4
    editor.dirty=False; editor.close()
print('Mode switch, bulk visibility, axis zoom, and mouse tie editing passed.')
