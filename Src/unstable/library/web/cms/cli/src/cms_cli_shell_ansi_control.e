note
	description: "Summary description for {CONSOLE_ANSI_CONTROL}."
	date: "$Date$"
	revision: "$Revision$"
	EIS: "name=ANSI escape codes (ASCII Table)", "protocol=URI", "src=http://ascii-table.com/ansi-escape-sequences.php"
	EIS: "name=ANSI escape codes (MS)", "protocol=URI", "src=https://docs.microsoft.com/en-us/windows/console/console-virtual-terminal-sequences"
	EIS: "name=ANSI escape codes (Wikipedia)", "protocol=URI", "src=https://en.wikipedia.org/wiki/ANSI_escape_code"
	EIS: "name=Box-drawing characters (Wikipedia)", "protocol=URI", "src=https://en.wikipedia.org/wiki/Box-drawing_characters"
	EIS: "name=ANSI escape codes (Gist)", "protocol=URI", "src=https://gist.github.com/fnky/458719343aabd01cfb17a3a4f7296797"

class
	CMS_CLI_SHELL_ANSI_CONTROL

inherit
	ANY
		redefine
			default_create
		end

create
	default_create

feature {NONE} -- Initialization

	default_create
		local
			i: INTEGER
		do
			io.output.end_of_file.do_nothing
			i := initialize_terminal
			ansi_enabled := (i = 0)
		end

	initialize_terminal: INTEGER
		external "C inline"
		alias "[
			#ifdef EIF_WINDOWS
				{
					HANDLE hOut = GetStdHandle(STD_OUTPUT_HANDLE);
					if (hOut == INVALID_HANDLE_VALUE) {
						return GetLastError();
					}
					DWORD dwMode = 0;
					if (!GetConsoleMode(hOut, &dwMode)) {
						return GetLastError();
					}
					dwMode |= ENABLE_VIRTUAL_TERMINAL_PROCESSING;
					if (!SetConsoleMode(hOut, dwMode)) {
						return GetLastError();
					}
					return 0;
				}
			#else
				/* Check for other platforms */
				return 0;
			#endif
			]"
		end

	ansi_enabled: BOOLEAN

feature -- Control

	set_control (m: READABLE_STRING_8)
			-- Send a raw ANSI control sequence (CSI + m).
			-- See: https://gist.github.com/fnky/458719343aabd01cfb17a3a4f7296797
		do
			if ansi_enabled then
				io.output.put_string ("%/27/[")
				io.output.put_string (m)
			end
		end

feature -- Control: attributes

	reset_attributes
			-- Reset all attributes (SGR 0)
			-- https://gist.github.com/fnky/458719343aabd01cfb17a3a4f7296797#reset
		do
			set_control ("0m")
		end

	set_bold
			-- Set bold (SGR 1)
		do
			set_control ("1m")
		end
	unset_bold
			-- Unset bold (SGR 22)
		do
			set_control ("22m")
		end
	set_dim_faint
			-- Set dim/faint (SGR 2)
		do
			set_control ("2m")
		end
	unset_dim_faint
			-- Unset dim/faint (SGR 22)
		do
			set_control ("22m")
		end
	set_italic
			-- Set italic (SGR 3)
		do
			set_control ("3m")
		end
	unset_italic
			-- Unset italic (SGR 23)
		do
			set_control ("23m")
		end
	set_underline
			-- Set underline (SGR 4)
		do
			set_control ("4m")
		end
	unset_underline
			-- Unset underline (SGR 24)
		do
			set_control ("24m")
		end
	set_blink
			-- Set blink (SGR 5)
		do
			set_control ("5m")
		end
	unset_blink
			-- Unset blink (SGR 25)
		do
			set_control ("25m")
		end
	set_reverse_video
			-- Set reverse video (SGR 7)
		do
			set_control ("7m")
		end
	unset_reverse_video
			-- Unset reverse video (SGR 27)
		do
			set_control ("27m")
		end
	set_hidden
			-- Set hidden (SGR 8)
		do
			set_control ("8m")
		end
	unset_hidden
			-- Unset hidden (SGR 28)
		do
			set_control ("28m")
		end
	set_strikethrought
			-- Set strikethrough (SGR 9)
		do
			set_control ("9m")
		end
	unset_strikethrought
			-- Unset strikethrough (SGR 29)
		do
			set_control ("29m")
		end

feature -- Control: foreground colors

	reset_foreground_color
			-- Reset foreground color (SGR 39)
		do
			set_control ("39m")
		end

	set_foreground_color_to_black
			-- Set foreground color to black (SGR 30)
		do
			set_control ("30m")
		end
	set_foreground_color_to_red
			-- Set foreground color to red (SGR 31)
		do
			set_control ("31m")
		end
	set_foreground_color_to_green
			-- Set foreground color to green (SGR 32)
		do
			set_control ("32m")
		end
	set_foreground_color_to_yellow
			-- Set foreground color to yellow (SGR 33)
		do
			set_control ("33m")
		end
	set_foreground_color_to_blue
			-- Set foreground color to blue (SGR 34)
		do
			set_control ("34m")
		end
	set_foreground_color_to_magenta
			-- Set foreground color to magenta (SGR 35)
		do
			set_control ("35m")
		end
	set_foreground_color_to_cyan
			-- Set foreground color to cyan (SGR 36)
		do
			set_control ("36m")
		end
	set_foreground_color_to_white
			-- Set foreground color to white (SGR 37)
		do
			set_control ("37m")
		end
	set_foreground_color_to_default
			-- Set foreground color to default (SGR 39)
		do
			set_control ("39m")
		end

feature -- Control: background colors

	reset_background_color
			-- Reset background color (SGR 49)
		do
			set_control ("49m")
		end

	set_background_color_to_black
			-- Set background color to black (SGR 40)
		do
			set_control ("40m")
		end
	set_background_color_to_red
			-- Set background color to red (SGR 41)
		do
			set_control ("41m")
		end
	set_background_color_to_green
			-- Set background color to green (SGR 42)
		do
			set_control ("42m")
		end
	set_background_color_to_yellow
			-- Set background color to yellow (SGR 43)
		do
			set_control ("43m")
		end
	set_background_color_to_blue
			-- Set background color to blue (SGR 44)
		do
			set_control ("44m")
		end
	set_background_color_to_magenta
			-- Set background color to magenta (SGR 45)
		do
			set_control ("45m")
		end
	set_background_color_to_cyan
			-- Set background color to cyan (SGR 46)
		do
			set_control ("46m")
		end
	set_background_color_to_white
			-- Set background color to white (SGR 47)
		do
			set_control ("47m")
		end
	set_background_color_to_default
			-- Set background color to default (SGR 49)
		do
			set_control ("49m")
		end

feature -- 256 colors

	set_256_foreground_color (a_code: INTEGER)
			-- Set 256-color foreground (SGR 38;5;<n>)
			-- See: https://gist.github.com/fnky/458719343aabd01cfb17a3a4f7296797#256-colors
		require
			a_code >= 0 and a_code < 256
		do
			set_control ("38;5;" + a_code.out + "m")
		end

	set_256_background_color (a_code: INTEGER)
			-- Set 256-color background (SGR 48;5;<n>)
		require
			a_code >= 0 and a_code < 256
		do
			set_control ("48;5;" + a_code.out + "m")
		end

feature -- RGB colors

	set_rgb_foreground_color (r, g, b: INTEGER)
			-- Set truecolor (24-bit) foreground (SGR 38;2;<r>;<g>;<b>)
			-- See: https://gist.github.com/fnky/458719343aabd01cfb17a3a4f7296797#true-color
		require
			r >= 0 and r < 256
			g >= 0 and g < 256
			b >= 0 and b < 256
		do
			set_control ("38;2;" + r.out + ";" + g.out + ";" + b.out + "m")
		end

	set_rgb_background_color (r, g, b: INTEGER)
			-- Set truecolor (24-bit) background (SGR 48;2;<r>;<g>;<b>)
		require
			r >= 0 and r < 256
			g >= 0 and g < 256
			b >= 0 and b < 256

		do
			set_control ("48;2;" + r.out + ";" + g.out + ";" + b.out + "m")
		end

feature -- Control

	move_cursor_to_column (a_column: INTEGER)
			-- Move cursor to column n (CSI nG)
			-- https://gist.github.com/fnky/458719343aabd01cfb17a3a4f7296797#cursor-position
		require
			valid_column: a_column >= 0 and a_column <= 32_767
		do
			set_control (a_column.out + "G")
		end

	move_cursor_to_line (a_line: INTEGER)
			-- Move cursor to line n (CSI nd)
		require
			valid_line: a_line >= 0 and a_line <= 32_767
		do
			set_control (a_line.out + "d")
		end

	move_cursor_to_home_position
			-- Move cursor to home position (CSI H)
		do
			set_control ("H")
		end
	move_cursor_to_position (a_line, a_column: INTEGER)
			-- Move cursor to (line, column) (CSI <l>;<c>H)
		do
			set_control (a_line.out + ";" + a_column.out + "H")
		end
	move_cursor_up (nb: INTEGER)
			-- Move cursor up n lines (CSI nA)
		do
			set_control (nb.out + "A")
		end
	move_cursor_down (nb: INTEGER)
			-- Move cursor down n lines (CSI nB)
		do
			set_control (nb.out + "B")
		end
	move_cursor_forward (nb: INTEGER)
			-- Move cursor forward n columns (CSI nC)
		do
			set_control (nb.out + "C")
		end
	move_cursor_backward (nb: INTEGER)
			-- Move cursor backward n columns (CSI nD)
		do
			set_control (nb.out + "D")
		end
	move_cursor_to_beginning_of_next_line (nb: INTEGER)
			-- Move cursor to beginning of n-th next line (CSI nE)
		do
			set_control (nb.out + "E")
		end
	move_cursor_to_beginning_of_previous_line (nb: INTEGER)
			-- Move cursor to beginning of n-th previous line (CSI nF)
		do
			set_control (nb.out + "F")
		end
	move_cursor_one_line_up
			-- Move cursor one line up, scrolling if needed (CSI M)
		do
			if ansi_enabled then
				Io.Output.put_string ("%/27/M")
			end
		end

	save_cursor
			-- Save cursor position (DEC: ESC 7)
		do
			if ansi_enabled then
				Io.Output.put_string ("%/27/7")
			end
		end

	restore_cursor
			-- Restore cursor position (DEC: ESC 8)
		do
			if ansi_enabled then
				Io.Output.put_string ("%/27/8")
			end
		end

	save_cursor_sco
			-- Save cursor position (SCO: CSI s)
		do
			set_control ("s")
		end
	restore_cursor_sco
			-- Restore cursor position (SCO: CSI u)
		do
			set_control ("u")
		end

	save_screen
			-- Save screen (CSI ?47l)
		do
			set_control ("?47l")
		end
	restore_screen
			-- Restore screen (CSI ?47h)
		do
			set_control ("?47h")
		end

	show_cursor
			-- Show cursor (CSI ?25h)
		do
			set_control ("?25h")
		end
	hide_cursor
			-- Hide cursor (CSI ?25l)
		do
			set_control ("?25l")
		end

	erase_display_from_cursor
			-- Erase display from cursor to end (CSI 0J)
		do
			set_control ("0J")
		end -- from the cursor position (inclusive) up to the end of the display
	erase_display_until_cursor
			-- Erase display from start to cursor (CSI 1J)
		do
			set_control ("1J")
		end -- from the beginning of the display up to the cursor (including the cursor position)
	erase_display
			-- Erase entire display (CSI 2J)
		do
			set_control ("2J")
		end
	erase_saved_lines
			-- Erase saved lines (CSI 3J)
		do
			set_control ("3J")
		end
	erase_line_from_cursor
			-- Erase line from cursor to end (CSI 0K)
		do
			set_control ("0K")
		end -- from the cursor position (inclusive) up to the end of the line
	erase_line_until_cursor
			-- Erase line from start to cursor (CSI 1K)
		do
			set_control ("1K")
		end -- from the beginning of the line up to the cursor (including the cursor position)
	erase_line
			-- Erase entire line (CSI 2K)
		do
			set_control ("2K")
		end

feature -- Modes

	enable_line_wrapping_mode
			-- Enable line wrapping mode (CSI ?7h)
		do
			set_control ("=7h")
		end
	reset_line_wrapping_mode
			-- Reset line wrapping mode (CSI ?7l)
		do
			set_control ("=l")
		end

note
	copyright: "2011-2025, Jocelyn Fiat, Javier Velilla, Eiffel Software and others"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"

end
