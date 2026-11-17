# XTC Python — whole-project correlation editor

Open **one `.xtci` or `.xtc` project**. All reference curves, core records,
parameters, correlation models and declared FT/FD dependencies load automatically.
The sidecar `.yrr` is also read when present. No per-parameter import is needed.

This is an incomplete port. Preserving every original scientific operation and
providing mouse controls for every keyboard workflow is the acceptance requirement.
See [the function checklist](docs/FUNCTION_PARITY.md) for all 56 functions in the
available C source and their individual implementation status. Full parity with
XTC 4.5.x requires its complete sources and supporting scientific libraries.

## Install and run

From this repository's root, use Conda on macOS, Windows or Linux:

```sh
conda create -n pmagsoft --override-channels -c conda-forge python=3.12 "pyside6>=6.8,<7"
conda activate pmagsoft
python main.py examples/black_sea_XTC/ALLSTARS_BlackSea_clean.xtci
```

The bundled Black Sea example includes its age models, data files and Y-axis
settings. XTC reports one malformed value on line 55 of
`M72-5-24GC3_simple.litho` and skips that lithology curve. Run `python main.py`
to start with an empty window. An existing Python 3.10+ environment can also install dependencies via
`python -m pip install -r requirements.txt`. On Linux with X11, Qt may require
the XCB cursor library (`xcb-util-cursor` on Conda Forge).

The desktop GUI has been tested on Linux. macOS and Windows still need native
testing. The prior C++/QML version is available in
[the repository history](https://github.com/botaoxiongyong/XTC/tree/bcffc995ab103d361276403ea176b5a7f3a690d4).

## Create a project

Choose **File → Create Project**. Pick a new project filename in a folder
containing the input files or their subfolders. Input filenames and relative
paths must be whitespace-free for the legacy XTC format.

- Use **Add parameter** and **Add core** to grow the matrix. Select a column and
  click **Rename parameter** to change its name.
- Double-click a **Reference** cell to choose that parameter’s reference file,
  description and columns. Double-click a core cell to assign that core’s data
  file. Unassigned core cells are written as `NO_DATA`.
- Column numbers start at 1. **Total numeric columns** is suggested when you
  browse for a file. Set **X** to the depth or age column and **Y** to the
  measurement column. Use **Copy columns**, **Paste columns** or **Reset columns**
  to reuse a selection.
- Select a core and open **Core settings** to name it, choose its age file, and
  optionally attach tephra or disturbance files. To create its initial age
  file, enter two depth/target pairs with increasing depths and targets.
- Click **Create Project** to write the `.xtci` and matching `.xtci.yrr` and open
  the result. Initial age files are created only if requested in Core settings.
  Existing files are protected against overwriting during creation.

The writer uses the original XTC directive order and the parameter-major YRR
matrix. The available 2010 C program has tighter dataset and parameter limits
than the Python editor.

## Mouse workflow

- **File → Open project**: load the full core/parameter matrix. All declared
  dependencies must be inside the selected project's folder tree.
- Use the arrow buttons or the parameter dropdown to navigate the same project.
- **Y limits** and **Linear / Log** apply to the selected curve for the current
  parameter. Leave a limit blank for Auto. Log requires positive data and limits.
  Existing `.yrr` settings load with the project, including axis direction.
  Applying a change immediately saves it to the project’s `.yrr` file.
  Saving requires write access to the project folder.
- Select a core to highlight it in red. Use **Select All** or **Deselect All**
  to show or hide all cores. The reference has its own checkbox.
- Curves are individually scaled and vertically offset, on a common correlated
  depth/age axis. These are display scales, not an amplitude transformation.
- Scroll to zoom the X axis around the pointer. Ctrl+scroll in either mode
  changes vertical overlap from stacked bands to fully overlaid curves, each
  scaled to its own minimum and maximum. Drag to pan in View Mode.
  **Edit → Fit all curves** resets both axes.
- Click **Switch to Edit Mode** to open the tie table. Click **Switch to View Mode**
  to return to browsing. Click a position
  on the selected core's band, then its match on the reference band to insert a
  tie. Drag a marker in the selected core's band to change its target coordinate.
  Source coordinates are editable in the table. Two initial ties are required
  for graphical editing; right-click the plot to enter the initial coordinates.
- In Edit Mode, right-click the selected core band and choose **Add age tie
  point here** to add a draggable vertical line immediately. The new marker
  starts on the current correlation model so it leaves the alignment unchanged
  until moved. Right-click near an existing marker to remove it. Use Undo to
  reverse either edit and **Save Project** to write edits to disk.
- Select rows in the table to highlight the corresponding lines in orange.
  Right-click the selected rows and choose **Remove tie points**. Uncheck
  **Refer age** to unlock a protected tie before moving or removing it. Crossed or
  duplicate tie coordinates are rejected. Undo/Redo applies across parameters.
- **One model per core** is shared across every parameter. Parameter navigation
  never creates an independent correlation model.
- **File → Save Project** writes edited tie points to their original age files
  using the project’s FC/GC references. Earlier Python XTC projects with
  embedded tie edits migrate those edits to the age files on the next save.
  Y-axis settings save separately to the matching `.yrr` as soon as they are applied.
- **Help → Project load report** lists missing/invalid files and import notes.
  `NO_DATA` cells remain absent; failed curves remain absent with a report.

## Implemented limits and scientific compatibility

Linear mapping is implemented for strictly increasing models. Samples outside the
tie range are excluded. The in-range mapping is tested against functions compiled
from the supplied C source. This is **not** validation of the entire application
against legacy XTC. The old C extrapolation reads beyond an array; it is not copied.

Repeated curve coordinates are preserved, including lithology steps. Numeric-prefix
rows with trailing annotations and text headings are supported with import notes.
Malformed numeric tokens are reported, not automatically corrected.

The project retains its existing FT/FD file references.
FT/FD overlays are pending. Stacking,
paleomagnetic utilities, transfer-function views and several axis/display controls
remain pending; consult the complete per-function checklist.

## Verification

```sh
python -m unittest discover -s tests -v
python tests/project_creation_smoke.py
python tests/gui_smoke.py
```

The GUI smoke tests use synthetic projects and run offscreen by default.
For the optional numerical check against the older C implementation, set
`XTC_REFERENCE_C` to your local copy of `xtc143.c` and run the unit tests
on a system with a C compiler. The source inventory can be regenerated with
`python tools/audit_c.py /path/to/xtc143.c` and `python tools/write_parity.py`.

Original scientific XTC: Dr. Norbert R. Nowaczyk, GFZ Potsdam. This repository
does not contain the complete original C source tree. See [LICENSE](LICENSE)
for the repository's GPL v3 license.
