# moldy-processing

This is a little Processing script (requires Processing 3 to run) that emulates 'cell' 'growth' that looks like 'mold'.

There is absolutely no scientific basis within the program; it is merely an experiment in pseudo-random growth patterns and energy management.

If you would like to try this out, please do! Note that a beefier machine may be helpful when running for long periods of time. Many options are provided for changing the behavior of the script.

>It is highly recommended that you double check through the below 'tweaks' to make sure the sketch runs the way you expect, especially those in **Moldy.pde**. I often use this repository to make updating my server easier, so they may be set to a headless mode that would be very boring to watch and very taxing on your computer.

Here are some recommended tweaks and their resultant behaviors:

- ***Moldy.pde***
	- `LIVING_TOL`: The higher this is, the fewer the cells lingering around at the edges.
	- `LOAD`: Indicates that the sketch should load a file into the field rather than start anew. This is automatically true if `HEADLESS_LFF` is true.
	- `LOAD_FILE`: The file from which to read. Automatically populated with information from `HEADLESS_BFN` if `_LFF` is true.
	- `HEADLESS`: Runs the sketch as quickly as possible without rendering anything; recommended for servers. Running on an actual headless server requires some addtional tweaking to allow Processing to open a virtual window.
		- `_RBS`: Determines the number of steps to **R**un **B**efore **S**aving to file.
		- `_ISF`: Determines if at each save, the sketch should **I**ncrement the **S**ave **F**ile number. If false, the previous file is overwritten. Note that no padding is performed, as the allowed max increment value is a signed `long` and that's a lot of digits.
		- `_BFN`: Determines the **B**ase **F**ile **N**ame to use while saving. Increments, if any, are appended to this name. An extension of *.mold* is automatically/always added.
		- `_LFF`: Indicates if the sketch should start by **L**oading **F**rom **F**ile. This will not look for the 'last known increment' of the provided file name; if you expect it to load from a incremented file, you must specify the entire filename less the extension (i.e. autosave26). If you then proceed with `ISF` enabled, a new number will be appended (i.e. autosave260, autosave261, ..., autosave2610, etc).

- ***Cell.pde***
	- `MAX_EXCITE`: Determines attenuation/amplification of a cell's incoming energy from neighbors.
	- `OFF_EXCITE`: Sets a minimum gain / maximum loss. If zero, cells may spawn that will die straight away. If greater than one, growth explosions are imminent and unstoppable.
	- `MAX_INSULA`: Determines how conservative a cell is with giving away its energy. Higher values reduce the energy output per cell.
	- `OFF_INSULA`: Sets a minimum fraction. If less than one, cells may attempt to give away more energy than they have. If too high, cells may not give energy out at all.
	- `MAX_RADIAT`: Determines the maximum percent of energy a cell may distribute. If greater than one, cells may give away all their energy at once (depending on `*_INSULA`).
	- `MIN_RADIAT`: Sets a minimum fraction. If set higher than `MAX_RADIAT`, cells never distribute. If set too low, cells will always attempt to distribute, even if they cannot distribute a significant amount.
	- There are also several places where a power function is used to determine rates relative to the distance between the cell and the origin. For example, lines 67-68 describe a 'living tax' that causes an energy drain. Altering `pow(dist,1.2)` can drastically prevent cells from surviving beyond a certain range. The values `0.00001` and `0.00005` are arbitrary and can also be tweaked.
	- The likelihood of two events can also be tweaked to affect the overall behavior of growth: the spawning of '*Chosen*' cells and '*Joy*'ous pulses. 
		- *Chosen* cells have a heartbeat that grant additional energy at regular intervals. Line 30 describes their chances of appearing; adjusting `r.nextInt(1000000)` can increase or decrease this. 
		- *Joy* is a random event that allows a cell to generate energy even if they aren't *Chosen*. Line 74 may be tweaked to change the likelihood of this. I've found that low values inhibit growth, but high values may spark explosions.
		
As well, if running the sketch in a normal (read: not headless) Processing environment, there are some key shortcuts that may be used while the sketch is active.

- `0~9`: Sets the number of steps to 'skip' between renders. Zero prevents any steps from occuring, one draws every step, two draws every other step, and so on. A maximum of nine steps may be skipped in this manner; if you need to skip more, `HEADLESS` mode may be more suitable for your needs.
- `r` (case matters): Resets the field. If a file is specified to be loaded, reloads the file; otherwise, starts from just one cell at the origin.
- `b`: Forces a re-calibration of the bounds of the field. Shouldn't be necessary.
- `g`: Toggles the use of the green channel to indicate energy amount; the sizes of each cell also indicate energy. Turn green off if you want to see the properties of the cells; red indicates *Excitability* and blue indicates *Insulation*.
- `s`: Forces a save of the file to the provided filename, if any. If none is provided, it saves to a new file with the timestamp of when the sketch was first started (repeatedly saving a file in this manner does not generate new files).
- `!`: Forces a crash to occur, halting all progress. A crash file should be outputted.