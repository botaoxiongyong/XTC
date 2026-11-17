"""Exercise File → Create Project and reload the written legacy files."""
import os
os.environ.setdefault('QT_QPA_PLATFORM', 'offscreen')

from pathlib import Path
import sys
from tempfile import TemporaryDirectory
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from PySide6.QtCore import QTimer
from PySide6.QtGui import QAction
from PySide6.QtWidgets import QApplication, QFileDialog, QInputDialog, QMessageBox, QPushButton

from app import Window
from project_builder import CurveFile, create_project
from project_dialog import CoreDialog, CurveDialog, ProjectDialog
from workspace import Workspace


def click(dialog, label):
    next(button for button in dialog.findChildren(QPushButton) if button.text() == label).click()


app = QApplication([])
window = Window()
with TemporaryDirectory() as folder:
    root = Path(folder)
    reference = root / 'reference.dat'
    reference.write_text('0 20 8\n10 30 15\n')
    data = root / 'core.dat'
    data.write_text('100 5 0\n200 9 20\n')
    ages = root / 'existing.ages'
    ages.write_text('0 0 1\n20 10 0\n')
    tephra = root / 'tephra.dat'
    tephra.write_text('5 6\n')
    disturbance = root / 'disturbance.dat'
    disturbance.write_text('9 10\n')
    original = {path: path.read_bytes() for path in root.iterdir()}
    project = root / 'example.xtci'
    initial = root / 'initial.ages'
    seen = {}

    def fill():
        dialog = QApplication.activeModalWidget()
        assert isinstance(dialog, ProjectDialog)
        seen['dialog'] = dialog
        with patch.object(QFileDialog, 'getSaveFileName', return_value=(str(project), '')):
            click(dialog, 'Browse…')
        with patch.object(QInputDialog, 'getText', return_value=('Susceptibility', True)):
            click(dialog, 'Rename parameter…')
        with patch.object(QInputDialog, 'getText', return_value=('Density', True)):
            click(dialog, 'Add parameter')

        def add_second_core(core_dialog):
            assert isinstance(core_dialog, CoreDialog)
            core_dialog.name.setText('Seaward')
            core_dialog.core.age_file = initial
            core_dialog.core.initial_ties = [[0, 0, 0], [20, 10, 0]]
            core_dialog.submit()
            return 1

        with patch.object(CoreDialog, 'exec', add_second_core):
            click(dialog, 'Add core')
        dialog.table.setCurrentCell(1, 0)

        def edit_first_core(core_dialog):
            core_dialog.name.setText('Landward')
            for attr, path in (('age_file', ages), ('tephra', tephra), ('disturbance', disturbance)):
                with patch.object(QFileDialog, 'getOpenFileName', return_value=(str(path), '')):
                    core_dialog.browse(attr)
            core_dialog.submit()
            return 1

        with patch.object(CoreDialog, 'exec', edit_first_core):
            click(dialog, 'Core settings…')

        def choose(path, row, column, x, y):
            dialog.table.setCurrentCell(row, column)

            def assign(curve_dialog):
                with patch.object(QFileDialog, 'getOpenFileName', return_value=(str(path), '')):
                    curve_dialog.browse()
                assert curve_dialog.count.value() == 3
                curve_dialog.x.setValue(x)
                curve_dialog.y.setValue(y)
                if curve_dialog.description is not None:
                    curve_dialog.description.setText(f'Reference {column + 1}')
                curve_dialog.submit()
                return 1

            with patch.object(CurveDialog, 'exec', assign):
                click(dialog, 'Choose data file…')

        choose(reference, 0, 0, 1, 2)
        choose(reference, 0, 1, 1, 3)
        choose(data, 1, 0, 3, 2)
        choose(data, 2, 1, 3, 1)
        assert not project.exists() and not initial.exists()
        if os.environ.get('XTC_CREATE_PREVIEW'):
            dialog.grab().save(os.environ['XTC_CREATE_PREVIEW'])
        click(dialog, 'Create Project')

    def fill_or_close():
        try:
            fill()
        except Exception as exc:
            seen['error'] = exc
            dialog = QApplication.activeModalWidget()
            if dialog:
                dialog.reject()

    QTimer.singleShot(0, fill_or_close)
    def unexpected_warning(_parent, title, message):
        seen['error'] = AssertionError(f'{title}: {message}')
        active = QApplication.activeModalWidget()
        if active:
            active.reject()

    with patch.object(QMessageBox, 'warning', unexpected_warning):
        next(action for action in window.findChildren(QAction) if action.text() == 'Create Project…').trigger()
    if 'error' in seen:
        raise seen['error']
    assert window.document.path == project
    loaded = Workspace.load(project)
    assert loaded.parameters == ['Susceptibility', 'Density']
    assert loaded.legacy.reference_comments == ['Reference 1', 'Reference 2']
    assert loaded.core_names == ['Landward', 'Seaward']
    assert loaded.references[1].points == [[0, 8], [10, 15]]
    assert loaded.curves[0][0].points == [[0, 5], [20, 9]]
    assert loaded.curves[1][1].points == [[0, 100], [20, 200]]
    assert loaded.curves[0][1] is None and loaded.curves[1][0] is None
    assert loaded.models == [[[0, 0, 1], [20, 10, 0]], [[0, 0, 0], [20, 10, 0]]]
    assert set(loaded.auxiliary) == {'tephra.dat', 'disturbance.dat'}
    assert len(loaded.style_settings) == 6 and not loaded.issues
    text = project.read_text()
    assert 'GP core.dat  3  3  2' in text and 'FP NO_DATA' in text
    assert 'FC existing.ages' in text and 'FC initial.ages' in text
    assert '  core.dat  3  3  2' in loaded.style_path.read_text()
    assert all(path.read_bytes() == contents for path, contents in original.items())
    draft = seen['dialog']
    try:
        create_project(project, draft.parameters, draft.cores)
    except ValueError as exc:
        assert 'already exists' in str(exc)
    else:
        raise AssertionError('Creation overwrote existing files')
    invalid = root / 'invalid.xtci'
    draft.cores[0].curves[0] = CurveFile(data, 3, 2, 2)
    try:
        create_project(invalid, draft.parameters, draft.cores)
    except ValueError as exc:
        assert 'distinct X and Y' in str(exc)
    else:
        raise AssertionError('Invalid column selection accepted')
    assert not invalid.exists() and not invalid.with_suffix('.xtci.yrr').exists()

print('Create Project menu, matrix, column assignments, initial age model, legacy files and reopen passed.')
