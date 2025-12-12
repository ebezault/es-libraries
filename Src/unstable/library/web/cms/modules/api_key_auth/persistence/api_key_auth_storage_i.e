note
	description: "Interface for accessing JWT token from the database."
	date: "$Date$"
	revision: "$Revision$"

deferred class
	API_KEY_AUTH_STORAGE_I

feature -- Error Handling

	error_handler: ERROR_HANDLER
			-- Error handler.
		deferred
		end

feature -- Access/token

	token (a_key_id: READABLE_STRING_GENERAL): detachable API_KEY_AUTH_TOKEN
			-- Token record for token  identified by `a_key_id`.
		require
			not_blank: not a_key_id.is_whitespace
		deferred
		end

	user_tokens (a_user: CMS_USER): detachable LIST [API_KEY_AUTH_TOKEN]
			-- Tokens associated with `a_user`.
		require
			valid_user: a_user.has_id
		deferred
		end

feature -- Change/token

	record_user_token (a_info: API_KEY_AUTH_TOKEN)
			-- Record `a_info` auth information.
		require
			user_has_id: a_info.user.has_id
			valid_token: not a_info.key.is_whitespace
		deferred
		end

	update_user_token (a_info: API_KEY_AUTH_TOKEN)
			-- Update `a_info` auth information.
			-- do not update: user, key_id, creation_date
		require
			user_has_id: a_info.user.has_id
			valid_token: not a_info.key.is_whitespace
		deferred
		end

	update_user_token_last_used (tok: API_KEY_AUTH_TOKEN; a_dt: DATE_TIME)
			-- Update `tok` last used date
		require
			user_has_id: tok.user.has_id
			valid_token: not tok.key.is_whitespace
		do
			tok.set_last_used_date (a_dt)
			update_user_token (tok)
		end

	discard_user_token (a_user: CMS_USER; a_key_id: READABLE_STRING_GENERAL)
			-- Discard `a_token` from `a_user`.
		require
			user_has_id: a_user.has_id
			valid_token: not a_key_id.is_whitespace
		deferred
		end

	discard_all_user_tokens (a_user: CMS_USER)
			-- Discard all tokens for `a_user`.
		require
			user_has_id: a_user.has_id
		deferred
		end

	discard_expired_or_revoked_tokens (dt: DATE_TIME; a_discarded_count: detachable CELL [INTEGER])
		deferred
		end

note
	copyright: "2011-2017, Jocelyn Fiat, Javier Velilla, Eiffel Software and others"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
end
