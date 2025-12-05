note
	description: "[
		JSON_ARRAY represent an array in JSON.
		An array in JSON is an ordered set of names.
		Examples
		array
		    []
		    [elements]
	]"
	author: "$Author$"
	date: "$date$"
	revision: "$Revision$"

class
	JSON_ARRAY

inherit
	JSON_VALUE
		redefine
			is_array,
			chained_item
		end

	ITERABLE [JSON_VALUE]

	DEBUG_OUTPUT

create
	make, make_empty,
	make_from_string_list,
	make_from_numeric_list,
	make_array

feature {NONE} -- Initialization

	make (nb: INTEGER)
			-- Initialize JSON array with capacity of `nb' items.
		do
			create items.make (nb)
		end

	make_empty
			-- Initialize empty JSON array.
		do
			make (0)
		end

	make_from_string_list (lst: ITERABLE [READABLE_STRING_GENERAL])
		do
			if attached {FINITE [READABLE_STRING_GENERAL]} lst as f then
				make (f.count)
			else
				make_empty
			end
			across
				lst as s
			loop
				extend_string (s)
			end
		end

	make_from_numeric_list (lst: ITERABLE [NUMERIC])
		do
			if attached {FINITE [NUMERIC]} lst as f then
				make (f.count)
			else
				make_empty
			end
			across
				lst as v
			loop
				extend_numeric (v)
			end
		end

	make_array
			-- Initialize JSON Array
		obsolete
			"Use `make' [2017-05-31]"
		do
			make (10)
		end

feature -- Status report			

	is_array: BOOLEAN = True
			-- <Precursor>

feature -- Access

	i_th alias "[]" (i: INTEGER): JSON_VALUE
			-- Item at `i'-th position
		require
			is_valid_index: valid_index (i)
		do
			Result := items.i_th (i)
		end

	chained_item alias "@" alias "/" (a_key: JSON_STRING): JSON_VALUE
			-- <Precursor>.
		do
			if a_key.item.is_integer then
				Result := i_th (a_key.item.to_integer)
			else
				Result := Precursor (a_key)
			end
		end

	representation: STRING
		do
			Result := "["
			across
				items as i
			loop
				if Result.count > 1 then
					Result.append_character (',')
				end
				Result.append (i.representation)
			end
			Result.append_character (']')
		end

feature -- Visitor pattern

	accept (a_visitor: JSON_VISITOR)
			-- Accept `a_visitor'.
			-- (Call `visit_json_array' procedure on `a_visitor'.)
		do
			a_visitor.visit_json_array (Current)
		end

feature -- Access

	new_cursor: ITERATION_CURSOR [JSON_VALUE]
			-- Fresh cursor associated with current structure
		do
			Result := items.new_cursor
		end

feature -- Mesurement

	count: INTEGER
			-- Number of items.
		do
			Result := items.count
		end

feature -- Status report

	is_empty: BOOLEAN
			-- Is structure empty?
		do
			Result := count = 0
		end

	valid_index (i: INTEGER): BOOLEAN
			-- Is `i' a valid index?
		do
			Result := (1 <= i) and (i <= count)
		end

feature -- Change Element

	put_front (v: JSON_VALUE)
		require
			v_not_void: v /= Void
		do
			items.put_front (v)
		ensure
			has_new_value: old items.count + 1 = items.count and items.first = v
		end

	add,
	extend (v: JSON_VALUE)
		require
			v_not_void: v /= Void
		do
			items.extend (v)
		ensure
			has_new_value: old items.count + 1 = items.count and items.has (v)
		end

	prune_all (v: JSON_VALUE)
			-- Remove all occurrences of `v'.
		require
			v_not_void: v /= Void
		do
			items.prune_all (v)
		ensure
			not_has_new_value: not items.has (v)
		end

	wipe_out
			-- Remove all items.
		do
			items.wipe_out
 		end

feature -- Helpers

	extend_string (s: READABLE_STRING_GENERAL)
		do
			extend (create {JSON_STRING}.make_from_string_general (s))
		end

	extend_numeric (v: NUMERIC)
		do
			extend (create {JSON_NUMBER}.make_numeric (v))
		end

	extend_integer_32 (i: INTEGER_32)
		do
			extend (create {JSON_NUMBER}.make_integer_32 (i))
		end

	extend_integer_64 (i: INTEGER_64)
		do
			extend (create {JSON_NUMBER}.make_integer (i))
		end

	extend_natural_32 (n: NATURAL_32)
		do
			extend (create {JSON_NUMBER}.make_natural_32 (n))
		end

	extend_natural_64 (n: NATURAL_64)
		do
			extend (create {JSON_NUMBER}.make_natural (n))
		end

	extend_real_32 (r: REAL_32)
		do
			extend (create {JSON_NUMBER}.make_real_32 (r))
		end

	extend_real_64 (r: REAL_64)
		do
			extend (create {JSON_NUMBER}.make_real (r))
		end

	extend_boolean (b: BOOLEAN)
		do
			extend (create {JSON_BOOLEAN}.make (b))
		end

	extend_null
		do
			extend (create {JSON_NULL})
		end

feature -- Report

	hash_code: INTEGER
			-- Hash code value
		local
			l_started: BOOLEAN
		do
			across
				items as i
			loop
				if l_started then
					Result := ((Result \\ 8388593) |<< 8) + i.hash_code
				else
					Result := i.hash_code
					l_started := True
				end
			end
			Result := Result \\ items.count
		end

feature -- Conversion

	array_representation: ARRAYED_LIST [JSON_VALUE]
			-- Representation as a sequences of values.
			-- be careful, modifying the return object may have impact on the original JSON_ARRAY object.		
		do
			Result := items
		end

feature -- Status report

	debug_output: STRING
			-- String that should be displayed in debugger to represent `Current'.
		do
			create Result.make (10)
			Result.append_integer (count)
			Result.append (" item")
			if count > 1 then
				Result.append_character ('s')
			end
		end

feature {NONE} -- Implementation

	items: ARRAYED_LIST [JSON_VALUE]
			-- Value container

invariant
	items_not_void: items /= Void

note
	copyright: "2010-2025, Jocelyn Fiat, Javier Velilla, Eiffel Software and others https://github.com/eiffelhub/json."
	license: "https://github.com/eiffelhub/json/blob/master/License.txt"
end
