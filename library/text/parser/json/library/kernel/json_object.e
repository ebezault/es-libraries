note
	description: "[
		            An JSON_OBJECT represent an object in JSON.
		            An object is an unordered set of name/value pairs
		
					Examples:
						object
						{}
						{"key": value}
						{"key": "value"}
	]"
	author: "$Author$"
	date: "$Date$"
	revision: "$Revision$"
	license: "MIT (see http://www.opensource.org/licenses/mit-license.php)"

class
	JSON_OBJECT

inherit
	JSON_VALUE
		redefine
			is_object,
			chained_item,
			has_key
		end

	TABLE_ITERABLE [JSON_VALUE, JSON_STRING]

	DEBUG_OUTPUT

create
	make_empty, make_with_capacity, make

feature {NONE} -- Initialization

	make_with_capacity (nb: INTEGER)
			-- Initialize with a capacity of `nb' items.
		do
			create items.make (nb)
		end

	make_empty
			-- Initialize as empty object.
		do
			make_with_capacity (0)
		end

	make
			-- Initialize with default capacity.
		do
			make_with_capacity (10)
		end

feature -- Status report			

	is_object: BOOLEAN = True
			-- <Precursor>		

feature -- Change Element

	put (a_value: detachable JSON_VALUE; a_key: JSON_STRING)
			-- Assuming there is no item of key `a_key',
			-- insert `a_value' with `a_key'.
		require
			a_key_not_present: not has_key (a_key)
		do
			if a_value = Void then
				put_null (a_key)
			else
				items.extend (a_value, a_key)
			end
		end

	replace (a_value: detachable JSON_VALUE; a_key: JSON_STRING)
			-- Associate `a_value` with `a_key`
			-- Replace existing value if any.
		do
			if a_value = Void then
				replace_with_null (a_key)
			else
				items.force (a_value, a_key)
			end
		end

	remove (a_key: JSON_STRING)
			-- Remove item indexed by `a_key' if any.
		do
			items.remove (a_key)
		end

	wipe_out
			-- Reset all items to default values; reset status.
		do
			items.wipe_out
		end

feature -- Helpers

	put_string (a_value: READABLE_STRING_GENERAL; a_key: JSON_STRING)
			-- Assuming there is no item of key `a_key',
			-- insert `a_value' with `a_key'.
		require
			key_not_present: not has_key (a_key)
		local
			l_value: JSON_STRING
		do
			if attached {READABLE_STRING_8} a_value as s then
				create l_value.make_from_string (s)
			elseif attached {READABLE_STRING_32} a_value as s32 then
				create l_value.make_from_string_32 (s32)
			else
				create l_value.make_from_string_32 (a_value.as_string_32)
			end
			put (l_value, a_key)
		end

	put_integer,
	put_integer_64 (a_value: INTEGER_64; a_key: JSON_STRING)
			-- Assuming there is no item of key `a_key',
			-- insert `a_value' with `a_key'.
		require
			key_not_present: not has_key (a_key)
		local
			l_value: JSON_NUMBER
		do
			create l_value.make_integer_64 (a_value)
			put (l_value, a_key)
		end

	put_integer_32 (a_value: INTEGER_32; a_key: JSON_STRING)
			-- Assuming there is no item of key `a_key',
			-- insert `a_value' with `a_key'.
		require
			key_not_present: not has_key (a_key)
		local
			l_value: JSON_NUMBER
		do
			create l_value.make_integer_32 (a_value)
			put (l_value, a_key)
		end

	put_natural,
	put_natural_64 (a_value: NATURAL_64; a_key: JSON_STRING)
			-- Assuming there is no item of key `a_key',
			-- insert `a_value' with `a_key'.
		require
			key_not_present: not has_key (a_key)
		local
			l_value: JSON_NUMBER
		do
			create l_value.make_natural_64 (a_value)
			put (l_value, a_key)
		end

	put_natural_32 (a_value: NATURAL_32; a_key: JSON_STRING)
			-- Assuming there is no item of key `a_key',
			-- insert `a_value' with `a_key'.
		require
			key_not_present: not has_key (a_key)
		local
			l_value: JSON_NUMBER
		do
			create l_value.make_natural_32 (a_value)
			put (l_value, a_key)
		end

	put_real,
	put_real_64 (a_value: REAL_64; a_key: JSON_STRING)
			-- Assuming there is no item of key `a_key',
			-- insert `a_value' with `a_key'.
		require
			key_not_present: not has_key (a_key)
		local
			l_value: JSON_NUMBER
		do
			create l_value.make_real_64 (a_value)
			put (l_value, a_key)
		end

	put_real_32 (a_value: REAL_32; a_key: JSON_STRING)
			-- Assuming there is no item of key `a_key',
			-- insert `a_value' with `a_key'.
		require
			key_not_present: not has_key (a_key)
		local
			l_value: JSON_NUMBER
		do
			create l_value.make_real_32 (a_value)
			put (l_value, a_key)
		end

	put_boolean (a_value: BOOLEAN; a_key: JSON_STRING)
			-- Assuming there is no item of key `a_key',
			-- insert `a_value' with `a_key'.
		require
			key_not_present: not has_key (a_key)
		local
			l_value: JSON_BOOLEAN
		do
			create l_value.make (a_value)
			put (l_value, a_key)
		end

	put_null (a_key: JSON_STRING)
			-- Assuming there is no item of key `a_key',
			-- insert Null with `a_key'.
		require
			key_not_present: not has_key (a_key)
		do
			put (create {JSON_NULL}, a_key)
		end

	replace_with_string (a_value: READABLE_STRING_GENERAL; a_key: JSON_STRING)
			-- Associate `a_value` with `a_key`
			-- Replace existing value if any.
		local
			l_value: JSON_STRING
		do
			if attached {READABLE_STRING_8} a_value as s then
				create l_value.make_from_string (s)
			else
				create l_value.make_from_string_32 (a_value.as_string_32)
			end
			replace (l_value, a_key)
		end

	replace_with_integer,
	replace_with_integer_64 (a_value: INTEGER_64; a_key: JSON_STRING)
			-- Associate `a_value` with `a_key`
			-- Replace existing value if any.
		local
			l_value: JSON_NUMBER
		do
			create l_value.make_integer_64 (a_value)
			replace (l_value, a_key)
		end

	replace_with_integer_32 (a_value: INTEGER_32; a_key: JSON_STRING)
			-- Associate `a_value` with `a_key`
			-- Replace existing value if any.
		local
			l_value: JSON_NUMBER
		do
			create l_value.make_integer_32 (a_value)
			replace (l_value, a_key)
		end

	replace_with_natural,
	replace_with_natural_64 (a_value: NATURAL_64; a_key: JSON_STRING)
			-- Associate `a_value` with `a_key`
			-- Replace existing value if any.
		local
			l_value: JSON_NUMBER
		do
			create l_value.make_natural_64 (a_value)
			replace (l_value, a_key)
		end

	replace_with_natural_32 (a_value: NATURAL_32; a_key: JSON_STRING)
			-- Associate `a_value` with `a_key`
			-- Replace existing value if any.
		local
			l_value: JSON_NUMBER
		do
			create l_value.make_natural_32 (a_value)
			replace (l_value, a_key)
		end

	replace_with_real,
	replace_with_real_64 (a_value: REAL_64; a_key: JSON_STRING)
			-- Associate `a_value` with `a_key`
			-- Replace existing value if any.
		local
			l_value: JSON_NUMBER
		do
			create l_value.make_real_64 (a_value)
			replace (l_value, a_key)
		end

	replace_with_real_32 (a_value: REAL_32; a_key: JSON_STRING)
			-- Associate `a_value` with `a_key`
			-- Replace existing value if any.
		local
			l_value: JSON_NUMBER
		do
			create l_value.make_real_32 (a_value)
			replace (l_value, a_key)
		end

	replace_with_boolean (a_value: BOOLEAN; a_key: JSON_STRING)
			-- Associate `a_value` with `a_key`
			-- Replace existing value if any.
		local
			l_value: JSON_BOOLEAN
		do
			create l_value.make (a_value)
			replace (l_value, a_key)
		end

	replace_with_null (a_key: JSON_STRING)
			-- Associate `a_value` with `a_key`
			-- Replace existing value if any.
		do
			replace (create {JSON_NULL}, a_key)
		end

feature -- Status report

	has_key (a_key: JSON_STRING): BOOLEAN
			-- has the JSON_OBJECT contains a specific key `a_key'.
		do
			Result := items.has (a_key)
		end

	has_item (a_value: JSON_VALUE): BOOLEAN
			-- has the JSON_OBJECT contain a specfic item `a_value'
		do
			Result := items.has_item (a_value)
		end

feature -- Access

	item alias "[]" (a_key: JSON_STRING): detachable JSON_VALUE
 			-- the json_value associated with a key `a_key'.
 		do
 			Result := items.item (a_key)
 		end


	string_item (a_key: JSON_STRING): detachable JSON_STRING
		do
			if attached {JSON_STRING} item (a_key) as js then
				Result := js
			end
		end

	number_item (a_key: JSON_STRING): detachable JSON_NUMBER
		do
			if attached {JSON_NUMBER} item (a_key) as jn then
				Result := jn
			end
		end

	boolean_item (a_key: JSON_STRING): detachable JSON_BOOLEAN
		do
			if attached {JSON_BOOLEAN} item (a_key) as jb then
				Result := jb
			end
		end

	object_item (a_key: JSON_STRING): detachable JSON_OBJECT
		do
			if attached {JSON_OBJECT} item (a_key) as jo then
				Result := jo
			end
		end

	array_item (a_key: JSON_STRING): detachable JSON_ARRAY
		do
			if attached {JSON_ARRAY} item (a_key) as ja then
				Result := ja
			end
		end

	chained_item alias "@" alias "/" (a_key: JSON_STRING): JSON_VALUE
			-- <Precursor>.
		do
			if attached item (a_key) as v then
				Result := v
			else
				Result := Precursor (a_key)
			end
		end

feature -- Access basic values

 	string_8_value (a_key: JSON_STRING): detachable READABLE_STRING_8
 		require
 			is_string_value: attached string_item (a_key)
 		do
 			if attached string_item (a_key) as js then
 				Result := js.unescaped_string_8
 			end
 		end

 	string_32_value (a_key: JSON_STRING): detachable READABLE_STRING_32
 		require
 			is_string_value: attached string_item (a_key)
 		do
 			if attached string_item (a_key) as js then
 				Result := js.unescaped_string_32
 			end
 		end

 	integer_32_value (a_key: JSON_STRING): INTEGER_32
		require
 			is_integer_32_value: attached number_item (a_key) as jnum and then jnum.is_integer_32
 		do
 			if attached number_item (a_key) as jnum then
 				if jnum.is_integer_32 then
	 				Result := jnum.integer_32_item
	 			else
	 				check is_integer_32: False end
	 			end
 			end
 		end

 	integer_64_value (a_key: JSON_STRING): INTEGER_64
		require
 			is_integer_64_value: attached number_item (a_key) as jnum and then jnum.is_integer_64
 		do
 			if attached number_item (a_key) as jnum then
 				if jnum.is_integer_64 then
	 				Result := jnum.integer_64_item
	 			else
	 				check is_integer_64: False end
	 			end
 			end
 		end

 	natural_32_value (a_key: JSON_STRING): NATURAL_32
		require
 			is_natural_32_value: attached number_item (a_key) as jnum and then jnum.is_natural_32
 		do
 			if attached number_item (a_key) as jnum then
 				if jnum.is_natural_32 then
	 				Result := jnum.natural_32_item
	 			else
	 				check is_natural_32: False end
	 			end
 			end
 		end

 	natural_64_value (a_key: JSON_STRING): NATURAL_64
		require
 			is_natural_64_value: attached number_item (a_key) as jnum and then jnum.is_natural_64
 		do
 			if attached number_item (a_key) as jnum then
 				if jnum.is_natural_64 then
	 				Result := jnum.natural_64_item
	 			else
	 				check is_natural_64: False end
	 			end
 			end
 		end

 	real_32_value (a_key: JSON_STRING): REAL_32
		require
 			is_real_32_value: attached number_item (a_key) as jnum and then jnum.is_real_32
 		do
 			if attached number_item (a_key) as jnum then
 				if jnum.is_real_32 then
	 				Result := jnum.real_32_item
	 			else
	 				check is_real_32: False end
	 			end
 			end
 		end

 	real_64_value (a_key: JSON_STRING): REAL_64
		require
 			is_real_64_value: attached number_item (a_key) as jnum and then jnum.is_real_64
 		do
 			if attached number_item (a_key) as jnum then
 				if jnum.is_real_64 then
	 				Result := jnum.real_64_item
	 			else
	 				check is_real_64: False end
	 			end
 			end
 		end

 	boolean_value (a_key: JSON_STRING): BOOLEAN
		require
 			is_boolean_value: attached boolean_item (a_key)
 		do
 			if attached boolean_item (a_key) as jbool then
	 			Result := jbool.item
 			end
 		end

feature -- Internal		

	current_keys: ARRAY [JSON_STRING]
			-- Array containing actually used keys.
		do
			Result := items.current_keys
		end

feature -- Conversion

	representation: STRING
			-- <Precursor>
		do
			create Result.make (2)
			Result.append_character ('{')
			across
				items as i
			loop
				if Result.count > 1 then
					Result.append_character (',')
				end
				Result.append (@i.key.representation)
				Result.append_character (':')
				Result.append (i.representation)
			end
			Result.append_character ('}')
		end

feature -- Mesurement

	count: INTEGER
			-- Number of field.
		do
			Result := items.count
		end

feature -- Access

	new_cursor: TABLE_ITERATION_CURSOR [JSON_VALUE, JSON_STRING]
			-- Fresh cursor associated with current structure
		do
			Result := items.new_cursor
		end

feature -- Status report

	is_empty: BOOLEAN
			-- Is empty object?
		do
			Result := items.is_empty
		end

feature -- Visitor pattern

	accept (a_visitor: JSON_VISITOR)
			-- Accept `a_visitor'.
			-- (Call `visit_json_object' procedure on `a_visitor'.)
		do
			a_visitor.visit_json_object (Current)
		end

feature -- Conversion

	map_representation: HASH_TABLE [JSON_VALUE, JSON_STRING]
			-- A representation that maps keys to values
		do
			Result := items
		end

feature -- Report

	hash_code: INTEGER
			-- Hash code value
		do
			from
				items.start
				Result := items.out.hash_code
			until
				items.off
			loop
				Result := ((Result \\ 8388593) |<< 8) + items.item_for_iteration.hash_code
				items.forth
			end
				-- Ensure it is a positive value.
			Result := Result.hash_code
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

	items: HASH_TABLE [JSON_VALUE, JSON_STRING]
			-- Value container

invariant
	items_not_void: items /= Void

note
	copyright: "2010-2025, Jocelyn Fiat, Javier Velilla, Eiffel Software and others https://github.com/eiffelhub/json."
	license: "https://github.com/eiffelhub/json/blob/master/License.txt"
end
