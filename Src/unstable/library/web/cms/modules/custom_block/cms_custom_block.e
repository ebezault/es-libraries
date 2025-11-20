note
	description: "Summary description for {CMS_CUSTOM_BLOCK}."
	date: "$Date$"
	revision: "$Revision$"

class
	CMS_CUSTOM_BLOCK

inherit
	DEBUG_OUTPUT

create
	make

feature {NONE} -- Initialization

	make (a_id: READABLE_STRING_8)
		do
			id := a_id
		end

feature -- Access

	id: IMMUTABLE_STRING_8

	title: detachable IMMUTABLE_STRING_32

	is_raw: BOOLEAN

	region: detachable READABLE_STRING_8

	weight: INTEGER_32

	template_engine_id: detachable READABLE_STRING_32

	conditions: detachable ARRAYED_LIST [CMS_BLOCK_EXPRESSION_CONDITION]

	debug_output: STRING_32
			-- String that should be displayed in debugger to represent `Current`.
		do
			create Result.make_from_string_general (id)
			if attached title as t then
				Result.append_string_general (t)
			end
		end

feature -- Status report

	is_template_engine (n: READABLE_STRING_GENERAL): BOOLEAN
		do
			if attached template_engine_id as e then
				Result := n.is_case_insensitive_equal (e)
			end
		end

	is_smarty_template_engine: BOOLEAN
		do
			if attached template_engine_id as e then
				Result := e.is_case_insensitive_equal ("smarty")
			else
					-- Default is smarty for now ...
				Result := True
			end
		end

feature -- Element change

	set_title (a_title: detachable READABLE_STRING_GENERAL)
		do
			if a_title = Void then
				title := Void
			else
				create title.make_from_string_general (a_title)
			end
		end

	set_is_raw (b: BOOLEAN)
		do
			is_raw := b
		end

	set_template_engine_id (v: detachable READABLE_STRING_32)
		do
			template_engine_id := v
		end

	set_region (r: like region)
		do
			region := r
		end

	set_weight (w: like weight)
		do
			weight := w
		end

	add_condition_expression (a_cond: READABLE_STRING_32)
		do
			add_condition (create {CMS_BLOCK_EXPRESSION_CONDITION}.make (a_cond))
		end

	add_condition (a_cond: CMS_BLOCK_EXPRESSION_CONDITION)
		local
			lst: like conditions
		do
			lst := conditions
			if lst = Void then
				create lst.make (1)
				conditions := lst
			end;
			lst.force (a_cond)
		end

end
