"""Mouse-driven editor for a new XTC core/parameter matrix."""
from dataclasses import replace
from pathlib import Path

from PySide6.QtCore import Qt
from PySide6.QtWidgets import (
    QAbstractItemView, QDialog, QDialogButtonBox, QFileDialog, QFormLayout,
    QHBoxLayout, QInputDialog, QLabel, QLineEdit, QMessageBox, QPushButton,
    QSpinBox, QTableWidget, QTableWidgetItem, QVBoxLayout, QWidget,
)

from core import validate_ties
from project_builder import Core, CurveFile, Parameter, create_project, detect_columns


def button(label, callback):
    widget = QPushButton(label)
    widget.clicked.connect(callback)
    return widget


def path_field(initial, choose, clear=None):
    field = QLineEdit(str(initial) if initial else '')
    field.setReadOnly(True)
    control = QWidget()
    layout = QHBoxLayout(control)
    layout.setContentsMargins(0, 0, 0, 0)
    layout.addWidget(field, 1)
    layout.addWidget(button('Browse…', choose))
    if clear is not None:
        layout.addWidget(button('Clear', clear))
    return control, field


class CurveDialog(QDialog):
    def __init__(self, parent, title, selection, directory, reference_name=None):
        super().__init__(parent)
        self.setWindowTitle(title)
        self.resize(620, 210)
        self.selection = selection
        self.directory = directory
        self.reference_name = reference_name
        self.path = selection.path if selection else None
        form = QFormLayout(self)
        file_control, self.file_field = path_field(self.path, self.browse)
        form.addRow('Data file', file_control)
        self.description = None
        if reference_name is not None:
            self.description = QLineEdit(reference_name)
            self.description.setPlaceholderText('Use the reference filename')
            form.addRow('Reference description', self.description)
        self.count = QSpinBox()
        self.x = QSpinBox()
        self.y = QSpinBox()
        self.count.setRange(2, 32767)
        self.count.valueChanged.connect(self.update_column_ranges)
        self.count.setValue(selection.count if selection else 2)
        self.update_column_ranges(self.count.value())
        self.x.setValue(selection.x if selection else 1)
        self.y.setValue(selection.y if selection else 2)
        form.addRow('Total numeric columns', self.count)
        form.addRow('X column (depth or age)', self.x)
        form.addRow('Y column (parameter)', self.y)
        buttons = QDialogButtonBox(QDialogButtonBox.StandardButton.Ok | QDialogButtonBox.StandardButton.Cancel)
        buttons.accepted.connect(self.submit)
        buttons.rejected.connect(self.reject)
        form.addRow(buttons)

    def update_column_ranges(self, count):
        self.x.setRange(1, count)
        self.y.setRange(1, count)

    def browse(self):
        start = self.path.parent if self.path else self.directory
        name, _ = QFileDialog.getOpenFileName(self, 'Choose data file', str(start))
        if not name:
            return
        path = Path(name)
        try:
            count = detect_columns(path)
        except (OSError, ValueError) as exc:
            QMessageBox.warning(self, 'Cannot use data file', str(exc))
            return
        self.path = path
        self.file_field.setText(str(path))
        if count != self.count.value():
            self.count.setValue(count)
            self.x.setValue(1)
            self.y.setValue(2)

    def submit(self):
        if self.path is None or self.x.value() == self.y.value():
            QMessageBox.warning(self, 'Data columns', 'Choose a file and distinct X and Y columns.')
            return
        self.selection = CurveFile(self.path, self.count.value(), self.x.value(), self.y.value())
        if self.description is not None:
            self.reference_name = self.description.text().strip()
        self.accept()


class CoreDialog(QDialog):
    def __init__(self, parent, core, directory):
        super().__init__(parent)
        self.setWindowTitle('Core settings')
        self.resize(670, 230)
        self.core = replace(core)
        self.directory = directory
        form = QFormLayout(self)
        self.name = QLineEdit(core.name)
        form.addRow('Core name', self.name)
        self.fields = {}
        for attr, label in (('age_file', 'Age model'), ('tephra', 'Tephra intervals'),
                            ('disturbance', 'Disturbance intervals')):
            field, text = path_field(
                getattr(core, attr), lambda key=attr: self.browse(key),
                None if attr == 'age_file' else lambda key=attr: self.clear(key),
            )
            self.fields[attr] = text
            form.addRow(label, field)
        form.addRow('', button('Create initial age model…', self.initial_model))
        if core.initial_ties is not None:
            self.show_initial_path()
        buttons = QDialogButtonBox(QDialogButtonBox.StandardButton.Ok | QDialogButtonBox.StandardButton.Cancel)
        buttons.accepted.connect(self.submit)
        buttons.rejected.connect(self.reject)
        form.addRow(buttons)

    def browse(self, attr):
        current = getattr(self.core, attr)
        name, _ = QFileDialog.getOpenFileName(self, 'Choose file', str(current.parent if current else self.directory))
        if name:
            setattr(self.core, attr, Path(name))
            if attr == 'age_file':
                self.core.initial_ties = None
            self.fields[attr].setText(name)

    def clear(self, attr):
        setattr(self.core, attr, None)
        self.fields[attr].clear()

    def show_initial_path(self):
        self.fields['age_file'].setText(f'{self.core.age_file} (new)')

    def initial_model(self):
        dialog = QDialog(self)
        dialog.setWindowTitle('Initial age model')
        form = QFormLayout(dialog)
        form.addRow(QLabel('Enter two known depth and target pairs in the project’s units.'))
        fields = []
        for label in ('Top depth', 'Top target age or depth', 'Bottom depth', 'Bottom target age or depth'):
            field = QLineEdit()
            fields.append(field)
            form.addRow(label, field)
        if self.core.initial_ties:
            values = [value for tie in self.core.initial_ties for value in tie[:2]]
            for field, value in zip(fields, values):
                field.setText(str(value))

        def submit():
            try:
                top, start, bottom, stop = (float(field.text()) for field in fields)
                if bottom <= top or stop <= start:
                    raise ValueError
                ties = validate_ties([[top, start, 0], [bottom, stop, 0]])
            except ValueError:
                QMessageBox.warning(dialog, 'Invalid tie points', 'Enter finite values with bottom depth and target greater than the top.')
                return
            name, _ = QFileDialog.getSaveFileName(dialog, 'Name the new age file',
                                                   str(self.directory / 'initial.ages'), 'Age models (*.ages);;All files (*)')
            if not name:
                return
            path = Path(name)
            if path.exists():
                QMessageBox.warning(dialog, 'Choose a new file', 'That age file already exists.')
                return
            self.core.age_file = path
            self.core.initial_ties = ties
            self.show_initial_path()
            dialog.accept()

        buttons = QDialogButtonBox(QDialogButtonBox.StandardButton.Ok | QDialogButtonBox.StandardButton.Cancel)
        buttons.accepted.connect(submit)
        buttons.rejected.connect(dialog.reject)
        form.addRow(buttons)
        dialog.exec()

    def submit(self):
        name = self.name.text().strip()
        if not name:
            QMessageBox.warning(self, 'Core settings', 'Enter a core name.')
            return
        self.core.name = name
        self.accept()


class ProjectDialog(QDialog):
    def __init__(self, parent=None, directory=None):
        super().__init__(parent)
        self.setWindowTitle('Create XTC Project')
        self.resize(930, 590)
        self.directory = Path(directory) if directory else Path.cwd()
        self.parameters = [Parameter('Parameter 1')]
        self.cores = [Core('Core 1')]
        self.path = None
        self.created_path = None
        self.copied_columns = None

        layout = QVBoxLayout(self)
        overview = QLabel('Assign a reference to each parameter and an age model to each core. '
                          'Double-click a cell to choose its data file and columns.')
        overview.setWordWrap(True)
        layout.addWidget(overview)
        form = QFormLayout()
        destination, self.destination_field = path_field(None, self.choose_destination)
        self.destination_field.setPlaceholderText('Choose where to create the .xtci and .yrr')
        form.addRow('Project file', destination)
        layout.addLayout(form)

        structure = QHBoxLayout()
        structure.addWidget(button('Add parameter', self.add_parameter))
        structure.addWidget(button('Rename parameter…', self.rename_parameter))
        structure.addWidget(button('Add core', self.add_core))
        self.core_settings_button = button('Core settings…', self.edit_core)
        structure.addWidget(self.core_settings_button)
        structure.addStretch()
        layout.addLayout(structure)

        self.table = QTableWidget()
        self.table.setSelectionMode(QAbstractItemView.SelectionMode.SingleSelection)
        self.table.setEditTriggers(QAbstractItemView.EditTrigger.NoEditTriggers)
        self.table.horizontalHeader().setDefaultSectionSize(190)
        self.table.horizontalHeader().setStretchLastSection(True)
        self.table.verticalHeader().sectionDoubleClicked.connect(self.edit_core_at)
        self.table.cellDoubleClicked.connect(self.edit_cell)
        self.table.currentCellChanged.connect(self.update_actions)
        layout.addWidget(self.table, 1)

        actions = QHBoxLayout()
        actions.addWidget(button('Choose data file…', self.edit_selected))
        self.clear_button = button('Clear data file', self.clear_selected)
        actions.addWidget(self.clear_button)
        self.copy_button = button('Copy columns', self.copy_columns)
        self.paste_button = button('Paste columns', self.paste_columns)
        self.reset_button = button('Reset columns', self.reset_columns)
        for control in (self.copy_button, self.paste_button, self.reset_button):
            actions.addWidget(control)
        actions.addStretch()
        layout.addLayout(actions)
        self.status = QLabel()
        self.status.setWordWrap(True)
        layout.addWidget(self.status)
        controls = QDialogButtonBox(QDialogButtonBox.StandardButton.Cancel)
        controls.rejected.connect(self.reject)
        create = controls.addButton('Create Project', QDialogButtonBox.ButtonRole.AcceptRole)
        create.clicked.connect(self.submit)
        layout.addWidget(controls)
        self.refresh_table(0, 0)

    def choose_destination(self):
        suggested = self.path if self.path else self.directory / 'project.xtci'
        name, _ = QFileDialog.getSaveFileName(
            self, 'Create XTC project', str(suggested), 'XTC import project (*.xtci)',
            options=QFileDialog.Option.DontConfirmOverwrite,
        )
        if name:
            self.path = Path(name).with_suffix('.xtci')
            self.directory = self.path.parent
            self.destination_field.setText(str(self.path))

    def curve(self, row, column):
        if row < 0 or column < 0:
            return None
        return self.parameters[column].reference if row == 0 else self.cores[row - 1].curves.get(column)

    def refresh_table(self, row, column):
        self.table.blockSignals(True)
        self.table.setColumnCount(len(self.parameters))
        self.table.setRowCount(len(self.cores) + 1)
        self.table.setHorizontalHeaderLabels([parameter.name for parameter in self.parameters])
        self.table.setVerticalHeaderLabels(['Reference'] + [core.name for core in self.cores])
        for index, core in enumerate(self.cores, 1):
            header = self.table.verticalHeaderItem(index)
            header.setToolTip(str(core.age_file) if core.age_file else 'Age model required. Double-click for core settings.')
        for r in range(self.table.rowCount()):
            for c in range(self.table.columnCount()):
                spec = self.curve(r, c)
                item = QTableWidgetItem(f'{spec.path.name}  ·  X{spec.x}, Y{spec.y}' if spec
                                        else ('Choose reference…' if r == 0 else 'NO_DATA'))
                if spec:
                    item.setToolTip(f'{spec.path}\n{spec.count} columns · X {spec.x} · Y {spec.y}')
                if r == 0:
                    font = item.font()
                    font.setBold(True)
                    item.setFont(font)
                self.table.setItem(r, c, item)
        self.table.setCurrentCell(row, column)
        self.table.blockSignals(False)
        self.update_actions()

    def update_actions(self, *_):
        row, column = self.table.currentRow(), self.table.currentColumn()
        spec = self.curve(row, column)
        self.core_settings_button.setEnabled(row > 0)
        self.clear_button.setEnabled(spec is not None)
        self.copy_button.setEnabled(spec is not None)
        self.paste_button.setEnabled(spec is not None and self.copied_columns is not None)
        self.reset_button.setEnabled(spec is not None)
        missing_ref = sum(parameter.reference is None for parameter in self.parameters)
        missing_ages = sum(core.age_file is None for core in self.cores)
        self.status.setText(f'{len(self.cores)} cores · {len(self.parameters)} parameters · '
                            f'{missing_ref} references to assign · {missing_ages} age models to assign')

    def add_parameter(self):
        index = len(self.parameters)
        name, ok = QInputDialog.getText(self, 'Add parameter', 'Parameter name', text=f'Parameter {index + 1}')
        if ok and name.strip():
            self.parameters.append(Parameter(name.strip()))
            self.refresh_table(self.table.currentRow(), index)

    def rename_parameter(self):
        column = self.table.currentColumn()
        parameter = self.parameters[column]
        name, ok = QInputDialog.getText(self, 'Rename parameter', 'Parameter name', text=parameter.name)
        if ok and name.strip():
            parameter.name = name.strip()
            self.refresh_table(self.table.currentRow(), column)

    def add_core(self):
        core = Core(f'Core {len(self.cores) + 1}')
        dialog = CoreDialog(self, core, self.directory)
        if dialog.exec():
            self.cores.append(dialog.core)
            self.refresh_table(len(self.cores), self.table.currentColumn())

    def edit_core_at(self, row):
        if row > 0:
            self.table.setCurrentCell(row, self.table.currentColumn())
            self.edit_core()

    def edit_core(self):
        row = self.table.currentRow()
        if row <= 0:
            return
        dialog = CoreDialog(self, self.cores[row - 1], self.directory)
        if dialog.exec():
            self.cores[row - 1] = dialog.core
            self.refresh_table(row, self.table.currentColumn())

    def edit_selected(self):
        self.edit_cell(self.table.currentRow(), self.table.currentColumn())

    def edit_cell(self, row, column):
        parameter = self.parameters[column]
        owner = 'Reference' if row == 0 else self.cores[row - 1].name
        dialog = CurveDialog(self, f'{owner} · {parameter.name}', self.curve(row, column),
                             self.directory, parameter.reference_name if row == 0 else None)
        if dialog.exec():
            if row == 0:
                parameter.reference_name = dialog.reference_name
            self.set_curve(row, column, dialog.selection)

    def set_curve(self, row, column, spec):
        if row == 0:
            self.parameters[column].reference = spec
        elif spec is None:
            self.cores[row - 1].curves.pop(column, None)
        else:
            self.cores[row - 1].curves[column] = spec
        self.refresh_table(row, column)

    def clear_selected(self):
        self.set_curve(self.table.currentRow(), self.table.currentColumn(), None)

    def copy_columns(self):
        spec = self.curve(self.table.currentRow(), self.table.currentColumn())
        self.copied_columns = (spec.count, spec.x, spec.y)
        self.update_actions()

    def paste_columns(self):
        row, column = self.table.currentRow(), self.table.currentColumn()
        self.set_curve(row, column, CurveFile(self.curve(row, column).path, *self.copied_columns))

    def reset_columns(self):
        row, column = self.table.currentRow(), self.table.currentColumn()
        self.set_curve(row, column, CurveFile(self.curve(row, column).path))

    def submit(self):
        if self.path is None:
            self.choose_destination()
        if self.path is None:
            return
        try:
            self.created_path = create_project(self.path, self.parameters, self.cores)
        except (OSError, ValueError) as exc:
            QMessageBox.warning(self, 'Could not create project', str(exc))
            return
        self.accept()
