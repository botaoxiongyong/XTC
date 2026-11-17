"""Project-first XTC editor with shared core models and stacked parameter curves."""
from bisect import bisect_left, bisect_right
import copy
import math
import sys
from pathlib import Path
from PySide6.QtCore import Qt, QPointF, QRectF
from PySide6.QtGui import QAction, QColor, QPainter, QPainterPath, QPen, QKeySequence
from PySide6.QtWidgets import (QApplication,QMainWindow,QWidget,QHBoxLayout,QVBoxLayout,
    QLabel,QPushButton,QToolButton,QMenu,QComboBox,QLineEdit,QListWidget,QListWidgetItem,QSplitter,
    QDockWidget,QTableWidget,QTableWidgetItem,QAbstractItemView,QFileDialog,QMessageBox)
from core import validate_ties, correlated_points, transform
from workspace import Workspace
from project_dialog import ProjectDialog
from yrr import YRange


class StackPlot(QWidget):
    def __init__(self,window):
        super().__init__(); self.window=window; self.limits=None; self.pending=None; self.drag=None
        self.vertical_overlap = 0.0
        self.cache={}; self.setMinimumSize(500,320); self.setMouseTracking(True)
        self.setToolTip('Scroll: zoom X · Ctrl+scroll: change vertical overlap · Right-click the selected core band for age tie points')
    def rect_plot(self):
        return QRectF(22, 24, max(1, self.width() - 44), max(1, self.height() - 62))
    def items(self):
        w=self.window
        if not w.document: return []
        p=w.parameter_index(); d=w.document; result=[]
        for row in range(w.records.count()):
            if w.records.item(row).checkState()!=Qt.CheckState.Checked: continue
            curve=d.references[p] if row==0 else d.curves[p][row-1]
            if curve is None: continue
            if row==0: points=curve.points
            else:
                ties=d.models[row-1]
                if len(ties)<2: continue
                key=(p,row,tuple(tuple(t) for t in ties))
                if key not in self.cache: self.cache[key]=correlated_points(curve,ties)
                points=self.cache[key]
            if points: result.append((row,curve,points))
        return result
    def bounds(self):
        if self.limits: return self.limits
        items=self.items()
        # Fit the reference to the cores' correlated interval, if one overlaps it.
        sources=[points for row,c,points in items if row]
        if sources:
            lo=min(p[0][0] for p in sources); hi=max(p[-1][0] for p in sources)
        elif items: lo,hi=items[0][2][0][0],items[0][2][-1][0]
        else: lo,hi=0,100
        return lo,hi if hi>lo else lo+1
    def px(self,x):
        lo,hi=self.bounds(); r=self.rect_plot(); return r.left()+(x-lo)/(hi-lo)*r.width()
    def value(self,x):
        lo,hi=self.bounds(); r=self.rect_plot(); return lo+(x-r.left())/r.width()*(hi-lo)
    def band(self,row):
        items=self.items(); rows=[r for r,c,p in items]
        if row not in rows: return None
        r = self.rect_plot()
        # Interpolate from stacked bands to a shared full-height plot.
        stacked_height = r.height() / len(rows)
        spacing = stacked_height * (1 - self.vertical_overlap)
        return QRectF(r.left(), r.top() + rows.index(row) * spacing,
                      r.width(), r.height() - (len(rows) - 1) * spacing)

    def paintEvent(self,event):
        painter=QPainter(self); painter.setRenderHint(QPainter.RenderHint.Antialiasing)
        painter.fillRect(self.rect(),QColor('#121319')); r=self.rect_plot()
        painter.fillRect(r,QColor('#292c35')); items=self.items(); w=self.window
        painter.setPen(QColor('#ced4df'))
        painter.drawText(QPointF(r.left(),16),'REFERENCE + CORES  /  individually scaled and vertically offset')
        if not items:
            message = 'No visible curves for this parameter.' if w.document else 'Open an XTC project (.xtci or .xtc).'
            painter.drawText(r, Qt.AlignmentFlag.AlignCenter, message)
            return
        lo,hi=self.bounds()
        for j in range(9):
            x=r.left()+j*r.width()/8
            painter.setPen(QColor('#e5e7eb')); painter.drawText(QPointF(x-14,r.bottom()+16),f'{lo+(hi-lo)*j/8:.4g}')
        painter.save(); painter.setClipRect(r)
        # Draw the active core last so it remains visible at full overlap.
        items.sort(key=lambda item: item[0] == w.records.currentRow())
        for row,c,points in items:
            band = self.band(row)
            if not band.intersects(r):
                continue
            setting = w.y_settings.get((w.parameter_index(), row), YRange())
            lower, upper = setting.lower, setting.upper
            scale_y = math.log10 if setting.logarithmic else float
            ys = [y for _, y in points if not setting.logarithmic or y > 0]
            if not ys:
                continue
            low = min(ys) if lower is None else lower
            high = max(ys) if upper is None else upper
            if high < low or (setting.logarithmic and low <= 0):
                continue
            low, high = scale_y(low), scale_y(high)
            selected=row==w.records.currentRow()
            color='#ff4d4f' if selected else ('#7dd3fc' if row==0 else '#d5d7dc')
            path=QPainterPath()
            # Display reduction keeps extrema per screen column; stored/exported data is untouched.
            buckets={}
            first = max(0, bisect_left(points, lo, key=lambda pair: pair[0]) - 1)
            last = min(len(points), bisect_right(points, hi, key=lambda pair: pair[0]) + 1)
            for x,y in points[first:last]:
                screen=self.px_fast(x,r,lo,hi)
                bucket=int(screen)
                buckets.setdefault(bucket,[]).append((x,y))
            reduced=[]
            for bucket,values in buckets.items():
                if len(values)<=4: reduced.extend(values)
                else:
                    ids=sorted({0,len(values)-1,min(range(len(values)),key=lambda i:values[i][1]),max(range(len(values)),key=lambda i:values[i][1])})
                    reduced.extend(values[i] for i in ids)
            padding = band.height() * .15 * (1 - self.vertical_overlap) + 3
            usable_height = max(1, band.height() - 2 * padding)
            start_segment = True
            for x, y in reduced:
                if setting.logarithmic and y <= 0:
                    start_segment = True
                    continue
                fraction = (scale_y(y) - low) / (high - low) if high != low else .5
                if setting.inverted:
                    fraction = 1 - fraction
                point = QPointF(self.px_fast(x,r,lo,hi), band.bottom() - padding - fraction * usable_height)
                if start_segment:
                    path.moveTo(point)
                else:
                    path.lineTo(point)
                start_segment = False
            painter.save()
            if lower is not None or upper is not None:
                painter.setClipRect(band.adjusted(0, padding, 0, -padding),
                                    Qt.ClipOperation.IntersectClip)
            painter.setPen(QPen(QColor(color), 1.5 if selected else 1))
            painter.drawPath(path)
            painter.restore()
            if self.vertical_overlap < .9 or selected:
                painter.setPen(QColor(color))
                name = 'Refer Data' if row == 0 else w.document.core_names[row-1]
                painter.drawText(QPointF(r.left()+5,band.top()+13), name)
        band = self.band(w.records.currentRow())
        if band and w.index() >= 0 and w.edit_mode.isChecked():
            selected_rows = {index.row() for index in w.table.selectionModel().selectedRows()}
            ties = enumerate(w.current_ties())
            for row, (_, target, protected) in sorted(ties, key=lambda entry: entry[0] in selected_rows):
                if lo <= target <= hi:
                    selected = row in selected_rows
                    color = '#f97316' if selected else '#ff4d4f' if protected else '#f8fafc'
                    painter.setPen(QPen(QColor(color), 2 if selected else 1))
                    x = self.px_fast(target, r, lo, hi)
                    painter.drawLine(QPointF(x, r.top()), QPointF(x, r.bottom()))
        if self.pending is not None:
            painter.setPen(QPen(QColor('#34d399'),2,Qt.PenStyle.DashLine))
            x=self.px_fast(self.pending[1],r,lo,hi); painter.drawLine(QPointF(x,r.top()),QPointF(x,r.bottom()))
        painter.restore(); painter.setPen(QColor('#9ca3af')); painter.drawRect(r)
        painter.drawText(QRectF(r.left(),self.height()-19,r.width(),17),Qt.AlignmentFlag.AlignCenter,'Correlated depth / age · original project units')
    @staticmethod
    def px_fast(x,r,lo,hi): return r.left()+(x-lo)/(hi-lo)*r.width()
    def reset(self):
        self.limits = None
        self.vertical_overlap = 0.0
        self.pending = None
        self.cache.clear()
        self.update()

    def wheelEvent(self, event):
        pixels = event.pixelDelta().y()
        steps = pixels / 80 if pixels else event.angleDelta().y() / 120
        if not steps or self.drag or not self.rect_plot().contains(event.position()) or not self.items():
            event.ignore()
            return
        steps = max(-10, min(10, steps))
        if event.modifiers() & Qt.KeyboardModifier.ControlModifier:
            self.vertical_overlap = max(0.0, min(1.0, self.vertical_overlap + .1 * steps))
        else:
            low, high = self.bounds()
            anchor = self.value(event.position().x())
            factor = .88 ** steps
            new_low = anchor + (low - anchor) * factor
            new_high = anchor + (high - anchor) * factor
            if new_high > new_low and all(map(math.isfinite, (new_low, new_high))):
                self.limits = new_low, new_high
        event.accept()
        self.update()

    def tie_at(self, position):
        band = self.band(self.window.records.currentRow())
        if self.window.index() < 0 or band is None or not self.rect_plot().contains(position):
            return None
        ties = self.window.current_ties()
        nearest = min(range(len(ties)), key=lambda i: abs(self.px(ties[i][1]) - position.x()), default=None)
        if nearest is not None and abs(self.px(ties[nearest][1]) - position.x()) < 7:
            return nearest
        return None

    def pick_source(self, position, ties):
        if len(ties) < 2:
            self.window.statusBar().showMessage('Right-click the plot to enter two initial tie points before graphical editing.')
            return
        reference_band = self.band(0)
        if reference_band is None:
            self.window.statusBar().showMessage('Show Refer Data before adding an age tie point on the plot.')
            return
        target = self.value(position.x())
        source = transform(target, [[t[1], t[0], t[2]] for t in ties], True)
        self.pending = (source, target)
        if self.vertical_overlap > 0:
            self.vertical_overlap = 0.0
        self.update()
        self.window.statusBar().showMessage('Click the matching position in the reference band to add the tie.')

    def finish_pick(self, position):
        source, _ = self.pending
        self.pending = None
        self.window.commit_ties(self.window.current_ties() + [[source, self.value(position.x()), 0]])

    def contextMenuEvent(self, event):
        window = self.window
        if not window.edit_mode.isChecked() or not self.rect_plot().contains(event.pos()):
            event.ignore()
            return
        point = QPointF(event.pos())
        row = window.records.currentRow()
        source = self.band(row) if row > 0 else None
        reference = self.band(0)
        finishing = self.pending is not None and reference is not None and reference.contains(point)
        needs_initial_ties = row > 0 and len(window.current_ties()) < 2
        index = self.tie_at(point)
        if index is None and not finishing and not needs_initial_ties and (source is None or not source.contains(point)):
            event.ignore()
            return

        ties = window.current_ties()
        menu = QMenu(self)
        if finishing:
            add = menu.addAction('Add age tie point here')
            add.triggered.connect(lambda: self.finish_pick(point))
        else:
            add = menu.addAction('Add age tie point here')
            add.setEnabled(index is None)
            if len(ties) >= 2:
                add.triggered.connect(lambda: self.add_tie_at(point))
            else:
                add.triggered.connect(window.add_tie)
        if index is not None:
            protected = ties[index][2]
            remove = menu.addAction('Remove age tie point (protected)' if protected else 'Remove age tie point')
            remove.setEnabled(not protected)
            remove.triggered.connect(lambda: window.commit_ties(ties[:index] + ties[index + 1:]))
        if self.pending is not None:
            cancel = menu.addAction('Cancel tie point')
            cancel.triggered.connect(self.cancel_pick)
        menu.aboutToHide.connect(menu.deleteLater)
        menu.popup(event.globalPos())

    def add_tie_at(self, position):
        ties = self.window.current_ties()
        target = self.value(position.x())
        source = transform(target, [[t[1], t[0], t[2]] for t in ties], True)
        self.limits = self.bounds()
        self.pending = None
        self.window.commit_ties(ties + [[source, target, 0]])
        if len(self.window.current_ties()) > len(ties):
            self.window.statusBar().showMessage('Age tie point added. Use Save Project to keep the edit on disk.')

    def cancel_pick(self):
        self.pending = None
        self.update()

    def mousePressEvent(self,event):
        w=self.window; pos=event.position(); r=self.rect_plot()
        if event.button()!=Qt.MouseButton.LeftButton or not r.contains(pos): return
        if not w.edit_mode.isChecked():
            self.drag=('pan',pos.x(),self.bounds()); return
        row=w.records.currentRow(); band=self.band(row)
        if row<=0 or not band: return
        ties=w.current_ties()
        reference = self.band(0)
        if self.pending is not None and reference is not None and reference.contains(pos):
            self.finish_pick(pos)
            return
        index = self.tie_at(pos)
        if index is None:
            if band.contains(pos):
                self.pick_source(pos, ties)
        elif ties[index][2]:
            w.statusBar().showMessage('Protected tie: uncheck Refer age in the table before editing.')
        else:
            self.limits = self.bounds()
            self.drag = ('tie', index, copy.deepcopy(ties), self.limits)

    def mouseMoveEvent(self,event):
        if not self.drag: return
        if self.drag[0]=='pan':
            _,x,(lo,hi)=self.drag; delta=(event.position().x()-x)/self.rect_plot().width()*(hi-lo)
            self.limits=(lo-delta,hi-delta); self.update()
        else:
            _,i,old,(lo,hi)=self.drag
            candidate=copy.deepcopy(old); candidate[i][1]=lo+(event.position().x()-self.rect_plot().left())/self.rect_plot().width()*(hi-lo)
            try: candidate=validate_ties(candidate)
            except ValueError: return
            self.window.document.models[self.window.index()]=candidate; self.cache.clear(); self.update()
    def mouseReleaseEvent(self,event):
        if self.drag and self.drag[0]=='tie':
            new=copy.deepcopy(self.window.current_ties()); old=self.drag[2]
            self.window.document.models[self.window.index()]=old; self.window.commit_ties(new)
        self.drag=None


class Window(QMainWindow):
    def __init__(self):
        super().__init__(); self.document=None; self.dirty=False; self.refreshing=False
        self.y_settings = {}
        self.undo_stack=[]; self.redo_stack=[]; self.resize(1380,850); self.setWindowTitle('XTC')
        file=self.menuBar().addMenu('&File'); edit=self.menuBar().addMenu('&Edit'); help_menu=self.menuBar().addMenu('&Help')
        for menu,label,slot,key in [(file,'Create Project…',self.create_project,'Ctrl+N'),(file,'Open project…',self.open_project,'Ctrl+O'),(file,'Save Project',self.save,'Ctrl+S'),(file,'Export selected correlated data…',self.export_data,None),(edit,'Undo',self.undo,'Ctrl+Z'),(edit,'Redo',self.redo,'Ctrl+Shift+Z'),(edit,'Fit all curves',lambda:self.plot.reset(),'Ctrl+0'),(help_menu,'Project load report',self.show_report,None)]:
            action=QAction(label,self); action.triggered.connect(lambda checked=False,f=slot:f())
            if key: action.setShortcut(QKeySequence(key))
            menu.addAction(action)
        split=QSplitter(); self.setCentralWidget(split)
        split.setHandleWidth(4)
        sidebar=QWidget(); left=QVBoxLayout(sidebar); split.addWidget(sidebar)
        left.setContentsMargins(5, 5, 5, 5)
        left.setSpacing(4)
        open_button = QPushButton('Open project…')
        open_button.clicked.connect(self.open_project)
        left.addWidget(open_button)
        self.edit_mode = QPushButton('Switch to Edit Mode')
        self.edit_mode.setCheckable(True)
        self.edit_mode.toggled.connect(self.mode_changed)
        left.addWidget(self.edit_mode)
        self.project_label=QLabel('No project loaded'); self.project_label.setWordWrap(True); left.addWidget(self.project_label)
        left.addWidget(QLabel('Cores · check to show / hide'))
        visibility_buttons = QHBoxLayout()
        left.addLayout(visibility_buttons)
        for label, visible in [('Select All', True), ('Deselect All', False)]:
            button = QPushButton(label)
            button.clicked.connect(lambda checked=False, show=visible: self.set_core_visibility(show))
            visibility_buttons.addWidget(button)
        self.records=QListWidget(); left.addWidget(self.records)
        self.records.currentRowChanged.connect(self.selection_changed); self.records.itemChanged.connect(lambda item:self.plot.update())
        self.controls_hint = QLabel('View Mode · scroll to zoom X\nCtrl+scroll to overlap curves\nDrag to pan')
        self.controls_hint.setWordWrap(True)
        left.addWidget(self.controls_hint)
        right=QWidget(); content=QVBoxLayout(right); content.setContentsMargins(2, 2, 2, 2); split.addWidget(right)
        content.setSpacing(3)
        split.setStretchFactor(0, 0)
        split.setStretchFactor(1, 1)
        split.setCollapsible(1, False)
        self.plot=StackPlot(self); content.addWidget(self.plot,1)
        navigation=QHBoxLayout(); content.addLayout(navigation)
        previous = QToolButton()
        previous.setArrowType(Qt.ArrowType.LeftArrow)
        previous.setToolTip('Previous parameter')
        previous.setAccessibleName('Previous parameter')
        previous.clicked.connect(lambda: self.step(-1))
        navigation.addWidget(previous)
        self.parameters = QComboBox()
        self.parameters.currentIndexChanged.connect(self.parameter_changed)
        navigation.addWidget(self.parameters, 1)
        following = QToolButton()
        following.setArrowType(Qt.ArrowType.RightArrow)
        following.setToolTip('Next parameter')
        following.setAccessibleName('Next parameter')
        following.clicked.connect(lambda: self.step(1))
        navigation.addWidget(following)

        navigation.addWidget(QLabel('Y limits'))
        self.y_min = QLineEdit()
        self.y_max = QLineEdit()
        for field, name, placeholder in ((self.y_min, 'Y minimum', 'Min auto'),
                                          (self.y_max, 'Y maximum', 'Max auto')):
            field.setPlaceholderText(placeholder)
            field.setAccessibleName(name)
            field.setToolTip(f'{name} for the selected curve. Leave blank for automatic scaling.')
            field.setFixedWidth(70)
            field.returnPressed.connect(self.apply_y_settings)
            navigation.addWidget(field)
        self.y_scale = QComboBox()
        self.y_scale.addItems(['Linear', 'Log'])
        self.y_scale.setAccessibleName('Y scale')
        self.y_scale.setToolTip('Y scale for the selected curve and parameter')
        self.y_scale.activated.connect(self.apply_y_settings)
        navigation.addWidget(self.y_scale)
        self.y_apply = QPushButton('Apply')
        self.y_apply.setToolTip('Apply Y limits to the selected curve')
        self.y_apply.clicked.connect(self.apply_y_settings)
        navigation.addWidget(self.y_apply)
        self.update_y_controls()
        split.setSizes([180, 1200])
        self.dock=QDockWidget('Selected core · correlation model',self); panel=QWidget(); box=QVBoxLayout(panel)
        box.setContentsMargins(3, 3, 3, 3)
        box.setSpacing(3)
        self.table = QTableWidget(0, 3)
        self.table.setHorizontalHeaderLabels(['Source depth', 'Target depth / age', 'Refer age'])
        self.table.setSelectionBehavior(QAbstractItemView.SelectionBehavior.SelectRows)
        self.table.setSelectionMode(QAbstractItemView.SelectionMode.ExtendedSelection)
        self.table.setContextMenuPolicy(Qt.ContextMenuPolicy.CustomContextMenu)
        self.table.customContextMenuRequested.connect(self.tie_table_menu)
        self.table.itemSelectionChanged.connect(self.plot.update)
        self.table.cellChanged.connect(self.table_changed)
        box.addWidget(self.table)
        legend = QLabel('Refer age ties are protected. Selected ties appear in orange.')
        legend.setWordWrap(True)
        box.addWidget(legend)
        self.dock.setWidget(panel); self.addDockWidget(Qt.DockWidgetArea.RightDockWidgetArea,self.dock); self.dock.hide()
        self.setStyleSheet('''QMainWindow,QWidget {background:#121319;color:#e5e7eb;font-size:12px}
        QMenuBar,QMenu {background:#22252e} QMenu::item:selected {background:#414754}
        QPushButton,QToolButton,QComboBox,QLineEdit {background:#242833;border:1px solid #505766;padding:5px}
        QPushButton:hover {background:#343b49} QPushButton:checked {background:#354a64;border-color:#82b4e8} QListWidget {border:1px solid #505766;background:#161820}
        QListWidget::item {padding:5px;border-bottom:1px solid #343a46} QListWidget::item:selected {background:#4d2730;color:#ff7779}
        QHeaderView::section {background:#292e38;padding:6px} QTableWidget {background:#1d2028;gridline-color:#414754}
        QSplitter::handle {background:#3d4350} QStatusBar {color:#aeb8ca}''')
        self.statusBar().showMessage('Open one .xtci project to load all parameters, cores and correlation files.')
    def parameter_index(self): return max(0,self.parameters.currentIndex())
    def index(self): return self.records.currentRow()-1
    def current_ties(self):
        return self.document.models[self.index()] if self.document and 0<=self.index()<len(self.document.models) else []
    def set_core_visibility(self, visible):
        # The reference curve has its own checkbox and is outside the core group.
        state = Qt.CheckState.Checked if visible else Qt.CheckState.Unchecked
        for row in range(1, self.records.count()):
            self.records.item(row).setCheckState(state)
        self.plot.cancel_pick()

    def mode_changed(self):
        editing = self.edit_mode.isChecked()
        self.edit_mode.setText('Switch to View Mode' if editing else 'Switch to Edit Mode')
        self.controls_hint.setText(
            'Edit Mode · scroll to zoom X\nCtrl+scroll to overlap curves\nRight-click a core band for age ties'
            if editing else 'View Mode · scroll to zoom X\nCtrl+scroll to overlap curves\nDrag to pan'
        )
        self.dock.setVisible(self.edit_mode.isChecked()); self.plot.pending=None; self.plot.update()
        self.table.setEnabled(self.edit_mode.isChecked())
    def selected_curve(self):
        row = self.records.currentRow()
        if not self.document or row < 0:
            return None
        parameter = self.parameter_index()
        return self.document.references[parameter] if row == 0 else self.document.curves[parameter][row - 1]

    def update_y_controls(self):
        enabled = self.selected_curve() is not None
        key = (self.parameter_index(), self.records.currentRow())
        setting = self.y_settings.get(key, YRange())
        self.y_min.setText('' if setting.lower is None else str(setting.lower))
        self.y_max.setText('' if setting.upper is None else str(setting.upper))
        self.y_scale.setCurrentIndex(int(setting.logarithmic))
        for widget in (self.y_min, self.y_max, self.y_scale, self.y_apply):
            widget.setEnabled(enabled)

    def apply_y_settings(self):
        curve = self.selected_curve()
        if curve is None:
            return
        key = (self.parameter_index(), self.records.currentRow())
        previous = self.y_settings.get(key, YRange())
        logarithmic = self.y_scale.currentIndex() == 1
        try:
            lower, upper = (float(field.text()) if field.text().strip() else None
                            for field in (self.y_min, self.y_max))
            if any(value is not None and not math.isfinite(value) for value in (lower, upper)):
                raise ValueError('Enter finite Y limits or leave the fields blank for Auto.')
            if logarithmic and (any(point[1] <= 0 for point in curve.points)
                                or any(value is not None and value <= 0 for value in (lower, upper))):
                raise ValueError('Log scale requires positive curve values and Y limits.')
            setting = YRange(lower, upper, logarithmic, previous.inverted)
            if setting == previous:
                return
            self.document.save_axis(*key, setting)
        except (OSError, ValueError) as exc:
            self.statusBar().showMessage(str(exc), 10000)
            self.y_scale.setCurrentIndex(int(previous.logarithmic))
            return
        self.statusBar().showMessage(f'Saved Y-axis settings to {self.document.style_path.name}.', 5000)
        self.plot.update()

    def parameter_changed(self):
        if self.document:
            p=self.parameter_index()
            for row in range(self.records.count()):
                curve=self.document.references[p] if row==0 else self.document.curves[p][row-1]
                item=self.records.item(row); name='Refer Data' if row==0 else self.document.core_names[row-1]
                item.setText(name+('  · no data' if curve is None else ''))
                item.setToolTip(curve.source if curve else 'NO_DATA or a failed import; see project report.')
            self.plot.reset(); self.refresh()
            self.update_y_controls()
    def selection_changed(self):
        self.plot.pending = None
        self.refresh()
        self.update_y_controls()
    def step(self,delta):
        if self.parameters.count(): self.parameters.setCurrentIndex((self.parameter_index()+delta)%self.parameters.count())
    def refresh(self):
        self.refreshing=True; self.table.setRowCount(len(self.current_ties()))
        for row,tie in enumerate(self.current_ties()):
            for col,value in enumerate(tie):
                item=QTableWidgetItem(f'{value:.10g}')
                if col==2:
                    item.setFlags(Qt.ItemFlag.ItemIsEnabled|Qt.ItemFlag.ItemIsSelectable|Qt.ItemFlag.ItemIsUserCheckable)
                    item.setCheckState(Qt.CheckState.Checked if value else Qt.CheckState.Unchecked)
                elif tie[2]: item.setFlags(Qt.ItemFlag.ItemIsEnabled|Qt.ItemFlag.ItemIsSelectable)
                self.table.setItem(row,col,item)
        self.refreshing=False; self.plot.update()
    def changed(self):
        self.dirty=True; self.setWindowTitle('XTC — '+self.document.path.name+' *')
    def commit_ties(self,ties):
        if not self.document or self.index()<0: return
        try: ties=validate_ties(ties)
        except ValueError as exc: self.error(exc); self.refresh(); return
        old=copy.deepcopy(self.current_ties())
        if old!=ties:
            self.undo_stack.append((self.index(),old,copy.deepcopy(ties))); self.redo_stack.clear()
            self.document.models[self.index()]=ties; self.changed(); self.plot.cache.clear()
        self.refresh()
    def table_changed(self,row,col):
        if self.refreshing: return
        try:
            ties=copy.deepcopy(self.current_ties()); item=self.table.item(row,col)
            ties[row][col]=int(item.checkState()==Qt.CheckState.Checked) if col==2 else float(item.text())
            self.commit_ties(ties)
        except ValueError as exc: self.error(exc); self.refresh()
    def add_tie(self):
        from PySide6.QtWidgets import QInputDialog
        if self.index()<0: return
        text,ok=QInputDialog.getText(self,'Add tie point','Source coordinate, target coordinate')
        if ok:
            try:
                values=[float(x) for x in text.replace(',',' ').split()]
                if len(values)!=2: raise ValueError('Enter two numbers.')
                self.commit_ties(self.current_ties()+[values+[0]])
            except ValueError as exc: self.error(exc)
    def tie_table_menu(self, position):
        if not self.edit_mode.isChecked():
            return
        row = self.table.rowAt(position.y())
        if row < 0:
            return
        selected_rows = {index.row() for index in self.table.selectionModel().selectedRows()}
        if row not in selected_rows:
            self.table.selectRow(row)
            selected_rows = {row}
        menu = QMenu(self.table)
        remove = menu.addAction('Remove tie points')
        remove.setEnabled(any(not self.current_ties()[index][2] for index in selected_rows))
        remove.triggered.connect(self.delete_ties)
        menu.aboutToHide.connect(menu.deleteLater)
        menu.popup(self.table.viewport().mapToGlobal(position))

    def delete_ties(self):
        rows={i.row() for i in self.table.selectionModel().selectedRows()}
        self.commit_ties([t for i,t in enumerate(self.current_ties()) if i not in rows or t[2]])
    def undo(self):
        if self.undo_stack:
            i,old,new=self.undo_stack.pop(); self.redo_stack.append((i,old,new)); self.document.models[i]=copy.deepcopy(old); self.records.setCurrentRow(i+1); self.changed(); self.plot.cache.clear(); self.refresh()
    def redo(self):
        if self.redo_stack:
            i,old,new=self.redo_stack.pop(); self.undo_stack.append((i,old,new)); self.document.models[i]=copy.deepcopy(new); self.records.setCurrentRow(i+1); self.changed(); self.plot.cache.clear(); self.refresh()
    def load_path(self,path):
        document=Workspace.load(path)
        self.document=document; self.y_settings=document.style_settings; self.undo_stack=[]; self.redo_stack=[]; self.dirty=False
        self.parameters.blockSignals(True); self.parameters.clear(); self.parameters.addItems(document.parameters); self.parameters.blockSignals(False)
        self.records.blockSignals(True); self.records.clear()
        for name in ['Refer Data']+document.core_names:
            item=QListWidgetItem(name); item.setCheckState(Qt.CheckState.Checked); self.records.addItem(item)
        self.records.setCurrentRow(1 if document.models else 0); self.records.blockSignals(False)
        self.project_label.setText(document.path.name); self.setWindowTitle('XTC — '+document.path.name); self.parameter_changed()
        self.statusBar().showMessage(f'Loaded {len(document.parameters)} parameters / {len(document.models)} cores / {len(document.files)} related files. {len(document.issues)} import issue(s) — see Project load report.')
    def create_project(self):
        if not self.confirm_discard():
            return
        directory = self.document.path.parent if self.document else None
        dialog = ProjectDialog(self, directory)
        if dialog.exec():
            try:
                self.load_path(dialog.created_path)
            except (OSError, ValueError) as exc:
                self.error(exc)

    def open_project(self):
        if not self.confirm_discard(): return
        path,_=QFileDialog.getOpenFileName(self,'Open XTC project','','XTC projects (*.xtci *.xtc)')
        if path:
            try: self.load_path(path)
            except (ValueError,OSError,IndexError,KeyError) as exc: self.error(exc)
    def save(self):
        if not self.document: return False
        try:
            count = self.document.save()
        except (ValueError, OSError) as exc:
            self.error(exc)
            return False
        self.dirty = False
        self.setWindowTitle('XTC — ' + self.document.path.name)
        message = f'Saved tie points to {count} age file(s).' if count else 'No age tie changes to save.'
        self.statusBar().showMessage(message, 5000)
        return True

    def export_data(self):
        if not self.document or self.index()<0: return
        try:
            curve=self.document.curves[self.parameter_index()][self.index()]
            if curve is None: raise ValueError('No curve for this parameter/core.')
            points=correlated_points(curve,self.current_ties())
            path,_=QFileDialog.getSaveFileName(self,'Export selected data','correlated.dat','ASCII data (*.dat)')
            if path: Path(path).write_text('# correlated_coordinate value\n'+''.join(f'{x:.17g} {y:.17g}\n' for x,y in points))
        except (ValueError,OSError) as exc: self.error(exc)
    def show_report(self):
        if not self.document: return
        d=self.document; dialog=QMessageBox(self); dialog.setWindowTitle('Project load report')
        dialog.setText(f'{len(d.parameters)} parameters, {len(d.models)} core models, {len(d.files)} dependencies loaded.\n{len(d.issues)} import issue(s).\nY-axis settings are loaded from .yrr when present.')
        dialog.setDetailedText('\n'.join(d.issues+d.notes) or 'No import issues.'); dialog.exec()
    def error(self,exc): QMessageBox.warning(self,'XTC',str(exc))
    def confirm_discard(self):
        if not self.dirty: return True
        answer=QMessageBox.question(self,'Unsaved edits','Save changes to the open project before continuing?',QMessageBox.StandardButton.Save|QMessageBox.StandardButton.Discard|QMessageBox.StandardButton.Cancel)
        return self.save() if answer==QMessageBox.StandardButton.Save else answer==QMessageBox.StandardButton.Discard
    def closeEvent(self,event):
        if self.confirm_discard(): event.accept()
        else: event.ignore()


def main():
    app=QApplication.instance() or QApplication(sys.argv); app.setStyle('Fusion'); window=Window()
    if len(sys.argv)>1:
        try: window.load_path(sys.argv[1])
        except (ValueError,OSError,IndexError) as exc: window.error(exc)
    window.showMaximized()
    return app.exec()
