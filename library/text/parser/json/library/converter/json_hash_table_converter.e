note
	description: "A JSON converter for HASH_TABLE [ANY, HASHABLE]"
	author: "Paul Cohen"
	date: "$Date$"
	revision: "$Revision$"
	file: "$HeadURL: $"

class
	JSON_HASH_TABLE_CONVERTER

obsolete
	"This JSON converter design has issues [Sept/2014]."

inherit

	JSON_CONVERTER

create
	make

feature {NONE} -- Initialization

	make
		do
			create object.make (0)
		end

feature -- Access

	object: HASH_TABLE [ANY, HASHABLE]

feature -- Conversion

	from_json (j: attached like to_json): like object
		do
			create Result.make (j.count)
			across
				j as v
			loop
				if attached json.object (v, Void) as l_object then
					if attached {HASHABLE} json.object (@v.key, Void) as h then
						Result.put (l_object, h)
					else
						check
							key_is_hashable: False
						end
					end
				else
					check
						object_attached: False
					end
				end
			end
		end

	to_json (o: like object): detachable JSON_OBJECT
		local
			js: JSON_STRING
			failed: BOOLEAN
			k: HASHABLE
		do
			create Result.make
			across
				o as v
			loop
				k := @v.key
				if attached {JSON_STRING} json.value (k) as l_key then
					js := l_key
				else
					if attached {READABLE_STRING_GENERAL} k as s_key then
						create js.make_from_string_general (s_key)
					else
						create js.make_from_string (k.out)
					end
				end
				if attached json.value (v) as jv then
					Result.put (jv, js)
				else
					failed := True
				end
			end
			if failed then
				Result := Void
			end
		end

note
	copyright: "2010-2025, Jocelyn Fiat, Javier Velilla, Eiffel Software and others https://github.com/eiffelhub/json."
	license: "https://github.com/eiffelhub/json/blob/master/License.txt"
end -- class JSON_HASH_TABLE_CONVERTER
