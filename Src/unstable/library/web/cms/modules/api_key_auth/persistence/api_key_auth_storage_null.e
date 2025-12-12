note
	description: "Interface for accessing API key from the database."
	date: "$Date$"
	revision: "$Revision$"

class
	API_KEY_AUTH_STORAGE_NULL

inherit
	API_KEY_AUTH_STORAGE_I

feature -- Error handler

	error_handler: ERROR_HANDLER
			-- Error handler.
		do
			create Result.make
		end

feature -- Access/token

	token (a_key_id: READABLE_STRING_GENERAL): detachable API_KEY_AUTH_TOKEN
			-- <Precursor>
		do
		end

	user_tokens (a_user: CMS_USER): detachable LIST [API_KEY_AUTH_TOKEN]
			-- <Precursor>
		do
		end

feature -- Change/token

	record_user_token (a_info: API_KEY_AUTH_TOKEN)
			-- <Precursor>
		do
		end

	update_user_token (a_info: API_KEY_AUTH_TOKEN)
			-- Rename `a_info` auth information.
		do
		end

	discard_user_token (a_user: CMS_USER; a_key_id: READABLE_STRING_GENERAL)
			-- Discard `a_key_id` from `a_user`.
		do
		end

	discard_all_user_tokens (a_user: CMS_USER)
			-- Discard all tokens for `a_user`.
		do
		end

	discard_expired_or_revoked_tokens (dt: DATE_TIME; a_discarded_count: detachable CELL [INTEGER])
		do
		end


note
	copyright: "2011-2017, Jocelyn Fiat, Javier Velilla, Eiffel Software and others"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
end
