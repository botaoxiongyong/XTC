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

In XTC, choose **File → Open project** and open [ALLSTARS_BlackSea_clean.xtci](examples/black_sea_XTC/ALLSTARS_BlackSea_clean.xtci) from the `examples/black_sea_XTC` folder. Use the arrows below the plot to switch between measurements. Choose **Switch to Edit Mode** to work with age tie points.

**File → Save Project** writes tie-point edits to the project's age files. If you want to keep an untouched copy of the example, duplicate the whole example folder before editing.

Original scientific XTC by Dr. Norbert R. Nowaczyk, GFZ Potsdam. [GPL v3 license](LICENSE).
