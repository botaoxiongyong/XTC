# XTC

XTC is a desktop app for viewing and correlating sediment-core records. This test version includes a Black Sea example to try right away.

## 1. Download XTC

Install [Anaconda](https://www.anaconda.com/download) if you don't have it. Then [download XTC as a ZIP file](https://github.com/botaoxiongyong/XTC/archive/refs/heads/master.zip) and unzip it.

Open **Anaconda Prompt** on Windows or **Terminal** on macOS or Linux.

## 2. Install with one command

Copy and paste this line into the prompt. You only need to do this once per computer. If you already have a working `pmagsoft` environment, skip to the next step.

```sh
conda create -y -n pmagsoft --override-channels -c conda-forge python=3.12 "pyside6>=6.8,<7"
```

## 3. Run XTC locally

In the same prompt, go to the unzipped `XTC-master` folder that contains `main.py`. If you unzipped it in Downloads, use the command for your computer:

- **Windows:** `cd /d "%USERPROFILE%\Downloads\XTC-master"`
- **macOS or Linux:** `cd ~/Downloads/XTC-master`

Then run these two lines:

```sh
conda activate pmagsoft
python main.py
```

Repeat this step whenever you want to open XTC.

## Try the Black Sea example

Choose **File → Open project** and open [ALLSTARS_BlackSea_clean.xtci](examples/black_sea_XTC/ALLSTARS_BlackSea_clean.xtci) from the `examples/black_sea_XTC` folder. If you want to experiment without changing the bundled example, duplicate the whole folder first.

## View and compare curves

| To do this | Use this control |
| --- | --- |
| Switch measurements | Use the arrows or the parameter list below the plot. |
| Show or hide a curve | Use its checkbox in the sidebar. **Select All** and **Deselect All** apply to cores. Use **Refer Data** for the reference curve. |
| Highlight a core | Click its name in the sidebar. |
| Zoom or pan | Scroll over the plot to zoom horizontally. Drag the plot in View Mode to pan. |
| Bring curves closer together | Hold **Ctrl** (**Command** on Mac) while scrolling up to overlap the curves. Scroll down to stack them again. |
| Reset the view | Choose **Edit → Fit all curves**. |
| Change a curve’s Y axis | Select the curve, set **Y limits** or choose **Linear** or **Log**, then click **Apply**. Clear a limit to use automatic scaling. Log scale requires positive values. |

## Edit and save age tie points

1. Select a core and click **Switch to Edit Mode** to show its tie-point table.
2. To align two features, click a position on the selected core, then click the matching position on the reference curve. To add a point along the current alignment, right-click the core’s curve and choose **Add age tie point here**.
3. Drag a vertical tie line to change its target age or depth. For an exact value, double-click the tie’s coordinate in the table. Selecting a row highlights its line in orange.
4. To delete ties, select their rows, right-click and choose **Remove tie points**. A checked **Refer age** box protects that tie from moving or deletion. Use **Edit → Undo** or **Redo** to reverse or restore your changes.
5. Choose **File → Save Project** to write the changes to the core’s age file. Each core shares one age model across all its measurements. Y-axis settings are saved to the project’s `.yrr` when you apply them.

Click **Switch to View Mode** to return to browsing. To save a separate data file with the correlated coordinates, select a core and choose **File → Export selected correlated data**.

## Create your own project

1. Choose **File → Create Project** and pick a name and folder for the `.xtci` file. Place the input files in that folder or its subfolders.
2. Use **Add parameter** and **Add core** to build the table. To change a parameter name, select its column and click **Rename parameter**.
3. Double-click a cell to choose a file. Set the **X column** to depth or age and the **Y column** to the measurement. Use the **Reference** row to assign a reference file for each parameter. Leave a core cell empty when that measurement is unavailable.
4. In **Core settings**, choose each core’s age file. If a core has no age file yet, choose **Create initial age model** and enter two known depth–age pairs.
5. Click **Create Project** to open the new project. XTC writes the project file and its companion `.yrr`.

Original scientific XTC by Dr. Norbert R. Nowaczyk, GFZ Potsdam. [GPL v3 license](LICENSE).
