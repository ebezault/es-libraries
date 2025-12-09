note
	description: "Summary description for {CMS_CLI_COMMAND_UTILITY}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	CMS_CLI_COMMAND_UTILITY

feature -- Utilities

	pop_arguments (args: detachable READABLE_STRING_32): TUPLE [arg, args: detachable READABLE_STRING_32]
		local
			a: READABLE_STRING_32
			l_args: READABLE_STRING_32
			i: INTEGER
		do
			if args /= Void and then not args.is_whitespace then
				from
					i := 1
				until
					i > args.count or args [i].is_space
				loop
					i := i + 1
				end
				if i > args.count then
					a := args
					l_args := Void
				else
					a := args.head (i - 1)
					l_args := args.substring (i + 1, args.count)
				end
			end
			Result := [a, l_args]
		end

feature -- Prompts		

	yes_no_question (sh: CMS_CLI_SHELL; a_prompt: READABLE_STRING_32; with_dft: BOOLEAN; dft: BOOLEAN; dft_if_error: BOOLEAN): BOOLEAN
		local
			s: STRING_32
			done: BOOLEAN
		do
			from

			until
				done
			loop
				if with_dft then
					if dft then
						s := question (sh, a_prompt + " [Y|n] ")
					else
						s := question (sh, a_prompt + " [y|N] ")
					end
				else
					s := question (sh, a_prompt + " [y|n] ")
				end
				s.adjust
				if s.is_empty then
					if with_dft then
						Result := dft
						done := True
					end
				else
					if
						s.is_case_insensitive_equal_general ("y")
						or s.is_case_insensitive_equal_general ("yes")
					then
						Result := True
						done := True
					elseif
						s.is_case_insensitive_equal_general ("n")
						or s.is_case_insensitive_equal_general ("no")
					then
						Result := False
						done := True
					elseif with_dft then
						Result := dft_if_error
						done := True
					else
						sh.put_warning_line ({STRING_32} "Invalid answer ["+ s +"]")
					end
				end
			end
		end

	question (sh: CMS_CLI_SHELL; a_prompt: READABLE_STRING_32): STRING_32
		local
			s: STRING_8
			utf: UTF_CONVERTER
		do
			sh.output.put_string_32 (a_prompt)
			io.input.read_line
			s := io.input.last_string
			s.adjust
			Result := utf.utf_8_string_8_to_string_32 (s)
		end

	choice (sh: CMS_CLI_SHELL; a_title, a_prompt: READABLE_STRING_32; a_values: ITERABLE [READABLE_STRING_GENERAL]; dft: detachable READABLE_STRING_32): detachable READABLE_STRING_32
		local
			i: INTEGER
			q: BOOLEAN
			s: STRING_8
			lst: STRING_TABLE [READABLE_STRING_32]
			l_dft_index: INTEGER
		do
			sh.output.put_string_32 (a_title)
			sh.output.put_new_line
			create lst.make (5)
			across
				a_values as v
			loop
				i := i + 1
				lst [i.out] := v
				if dft /= Void and then dft.same_string (v) then
					lst [""] := v
					l_dft_index := i
				end
				sh.output.put_string (" [" + i.out + "] ")
				sh.output.put_string_32 (v)
				sh.output.put_new_line
			end
			from
			until
				Result /= Void or q
			loop
				sh.output.put_string (" ")
				sh.output.put_string_32 (a_prompt)
				if l_dft_index > 0 then
					sh.output.put_string_32 ("[" + l_dft_index.out + "]")
				end
				sh.output.put_string_32 (" : ")
				io.input.read_line
				s := io.input.last_string
				s.adjust
				if s.is_case_insensitive_equal ("q") then
					q := True
				else
					Result := lst [s]
--					if Result = Void then
--						
--					end
				end
			end
		end

feature -- Output helpers		

	output_h1 (sh: CMS_CLI_SHELL; s: READABLE_STRING_GENERAL)
		do
--			sh.ansi.set_foreground_color_to_cyan
			sh.ansi.set_bold

			sh.output.put_string_general (s)

			sh.ansi.unset_bold
--			sh.ansi.reset_foreground_color
			sh.output.put_new_line
		end

	output_h2 (sh: CMS_CLI_SHELL; s: READABLE_STRING_GENERAL)
		do
--			sh.ansi.set_foreground_color_to_cyan
			sh.ansi.set_bold

			sh.output.put_string_general (s)

			sh.ansi.unset_bold
--			sh.ansi.reset_foreground_color
			sh.output.put_new_line
		end

	output_key (sh: CMS_CLI_SHELL; s: READABLE_STRING_GENERAL)
		do
			sh.ansi.set_foreground_color_to_yellow
			sh.ansi.set_bold
			sh.output.put_string_general (s)
			sh.ansi.unset_bold
			sh.ansi.reset_foreground_color
		end

	output_information (sh: CMS_CLI_SHELL; s: READABLE_STRING_GENERAL)
		do
			sh.ansi.set_foreground_color_to_cyan
			sh.ansi.set_italic
			sh.output.put_string_general (s)
			sh.ansi.unset_italic
			sh.ansi.reset_foreground_color
		end

	output_help (sh: CMS_CLI_SHELL; s: READABLE_STRING_GENERAL)
		do
			sh.ansi.set_foreground_color_to_default
			sh.ansi.set_italic
			sh.output.put_string_general (s)
			sh.ansi.unset_italic
			sh.ansi.reset_foreground_color
		end

end
