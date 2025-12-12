note
	description: "Class representing an API key authentication token with associated metadata and operations."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	API_KEY_AUTH_TOKEN

create
	make_new,
	make

feature {NONE} -- Initialization

	make_new (a_user: CMS_USER; a_key_id: like key; a_date: DATE_TIME)
			-- Creates a new token for `a_user` with `a_key_id` and creation date `a_date`.
			-- Generates a new secret and hashes it for storage.
		local
			sec: like secret
		do
			sec := a_key_id + "_" + new_secret (40, a_date.second)

			user := a_user
			key_id := a_key_id
			secret := sec
			creation_date := a_date
			status := status_active
			key := hash_for_key (sec)
		end

	make (a_user: CMS_USER; a_key_id: READABLE_STRING_8; a_hashed_key: like key)
			-- Creates a token from existing data with `a_user`, `a_key_id` and pre-hashed `a_hashed_key`.
		do
			user := a_user
			key_id := a_key_id
			key := a_hashed_key
			secret := Void
			status := status_active
		end

feature -- Access

	user: CMS_USER
			-- Associated CMS user

	name: detachable READABLE_STRING_GENERAL
			-- Optional name for the token

	key_id: IMMUTABLE_STRING_8
			-- Unique identifier for the token

	key: READABLE_STRING_8
			-- Hashed version of the secret key

	secret: detachable READABLE_STRING_8
			-- Original secret key (only available before hashing)

	creation_date: detachable DATE_TIME
			-- When the token was created

	expiration_date: detachable DATE_TIME
			-- When the token expires

	last_used_date: detachable DATE_TIME
			-- Last time the token was used

	scopes: detachable LIST [READABLE_STRING_GENERAL]
			-- List of permissions granted to this token

	status: INTEGER
			-- Current status of the token

	data: detachable READABLE_STRING_8
			-- Additional metadata for the token

feature -- Conversion

	scopes_as_csv: detachable STRING_32
			-- Comma-separated list of all scopes
		do
			if attached scopes as l_scopes and then not l_scopes.is_empty then
				create Result.make_empty
				across
					l_scopes as s
				loop
					if not Result.is_empty then
						Result.append_character (',')
					end
					Result.append_string_general (s)
				end
			end
		end

feature -- Constants

	status_active: INTEGER = 1
			-- Token is active and can be used

	status_revoked: INTEGER = 2
			-- Token has been revoked and cannot be used

	status_inactive: INTEGER = 3
			-- Token is temporarily inactive

	status_expired: INTEGER = 4
			-- Token has expired and cannot be used

feature -- Status report

	is_hashed_token: BOOLEAN
			-- Whether the token has been hashed (secret is no longer available)
		do
			Result := secret = Void
		end

	is_active: BOOLEAN
			-- Whether the token is currently active and not expired
		do
			Result := status = status_active and then
				 not is_expired (Void)
		end

	is_revoked: BOOLEAN
			-- Whether the token has been revoked
		do
			Result := status = status_revoked
		end

	is_inactive: BOOLEAN
			-- Whether the token is inactive
		do
			Result := status = status_inactive
		end

	is_expired (dt: detachable DATE_TIME): BOOLEAN
			-- Whether the token has expired at time `dt` (or current time if `dt` is Void)
		do
			if
				dt = Void and -- TODO: is it needed ?
				status = status_expired
			then
				Result := True
			elseif attached expiration_date as l_expi then
				if dt /= Void then
					Result := dt > l_expi
				else
					Result := (create {DATE_TIME}.make_now_utc) > l_expi
				end
			end
		end

feature -- Basic operations

	is_valid_hashed_key (a_key: READABLE_STRING_8): BOOLEAN
			-- Whether `a_key` matches the stored hashed key
		require
			is_hashed_token
		do
			Result := key.is_case_insensitive_equal (hash_for_key (a_key))
		end

	prepare
			-- Prepares token for storage by hashing if needed and checking expiration
		do
			if not is_hashed_token then
				hash_token
					-- Check expiration
				if status = status_active then
					if is_expired (Void) then
						set_status (status_expired)
					end
				end
			end
		end

	hash_token
			-- Hashes the secret key and removes the original secret
		require
			not is_hashed_token
		do
			if attached secret as sec then
				key := hash_for_key (sec)
				secret := Void
			else
				check not is_hashed_token end
			end
		ensure
			attached (old secret) as l_secret implies is_valid_hashed_key (key)
		end

	hash_for_key (k: READABLE_STRING_8): STRING_8
			-- Hashed version of key `k` using bcrypt and SHA256
		local
			b: BCRYPT
			sh: SHA256
			s: STRING_8
		do
			create b.make_with_salt_generator (create {SALT_XOR_SHIFT_64_GENERATOR}.make (8))
			s := b.hashed_password_general (k, k)

			create sh.make
			sh.update_from_string (s)
			Result := sh.digest_as_hexadecimal_string
		end

	set_inactive
			-- Marks the token as inactive
		require
			is_active
		do
			status := status_inactive
		end

	set_active
			-- Marks the token as active
		require
			is_inactive
		do
			status := status_active
		end

	set_revoked
			-- Marks the token as revoked
		require
			not is_revoked
		do
			status := status_revoked
		end

feature -- Element change

	set_user (u: like user)
			-- Sets the associated user to `u`
		do
			user := u
		end

	set_name (n: detachable READABLE_STRING_GENERAL)
			-- Sets the token name to `n` if not empty
		do
			if n = Void or else n.is_whitespace then
				name := Void
			else
				name := n
			end
		end

	set_secret (sec: like secret)
			-- Sets the secret key to `sec`
		do
			secret := sec
		end

	set_creation_date (dt: DATE_TIME)
			-- Sets the creation date to `dt`
		do
			creation_date := dt
		end

	set_expiration_date (dt: detachable DATE_TIME)
			-- Sets the expiration date to `dt`
		do
			expiration_date := dt
		end

	set_last_used_date (dt: like last_used_date)
			-- Sets the last used date to `dt`
		do
			last_used_date := dt
		end

	set_data (d: like data)
			-- Sets the additional data to `d`
		do
			data := d
		end

	set_scopes (a_scopes: detachable ITERABLE [READABLE_STRING_GENERAL])
			-- Sets the token scopes to `a_scopes`
		do
			reset_scopes
			if a_scopes /= Void then
				across
					a_scopes as v
				loop
					set_scope (v)
				end
			end
		end

	set_scopes_from_csv (csv: READABLE_STRING_GENERAL)
			-- Sets the token scopes from comma-separated list `csv`
		do
			across
				csv.split (',') as v
			loop
				set_scope (v)
			end
		end

	reset_scopes
			-- Removes all scopes from the token
		do
			scopes := Void
		end

	set_scope (scp: READABLE_STRING_GENERAL)
			-- Adds `scp` to the list of token scopes after trimming whitespace
		local
			lst: like scopes
			s: STRING_32
		do
			lst := scopes
			if lst = Void then
				create {ARRAYED_LIST [READABLE_STRING_GENERAL]} lst.make (1)
				scopes := lst
			end
			s := scp.as_string_32
			s.left_adjust
			s.right_adjust
			lst.force (s)
		end

	unset_scope (sc: READABLE_STRING_GENERAL)
			-- Removes scope `sc` from the token's scope list if present
			-- Comparison is case-insensitive
		local
			lst: like scopes
		do
			lst := scopes
			if lst /= Void and then not lst.is_empty then
				from
					lst.start
				until
					lst.after
				loop
					if sc.is_case_insensitive_equal (lst.item) then
						lst.remove
					else
						lst.forth
					end
				end
			end
		end

	set_status (s: like status)
			-- Sets the token status to `s`
			-- Valid statuses are: active, revoked, inactive, or expired
		require
			s = status_active
			or s = status_revoked
			or s = status_inactive
			or s = status_expired
		do
			status := s
		end

feature {NONE} -- Implementation

	new_secret (len, off: INTEGER): STRING_8
			-- A random hexadecimal string of length `len`
			-- `off` is used as an offset for the random number generator
		local
			rand: RANDOM
			n: INTEGER
			v: NATURAL_32
		do
			rand := random_generator
			create Result.make (len)
			from
				n := off
			until
				n = 0
			loop
				n := n - 1
				rand.forth
			end
			from
				n := 1
			until
				n = len
			loop
				rand.forth
				v := (rand.item \\ 16).to_natural_32
				check 0 <= v and v <= 15 end
				if v < 9 then
					Result.append_code (48 + v) -- 48 '0'
				else
					Result.append_code (97 + v - 9) -- 97 'a'
				end
				n := n + 1
			end
		end

	random_generator: RANDOM
			-- A seeded random number generator for cryptographic operations
		once
			create Result.make
			Result.set_seed ({CMS_API}.random_seed)
			Result.start
		end

end
