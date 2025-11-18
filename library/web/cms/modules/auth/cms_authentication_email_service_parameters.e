note
	description: "Summary description for {CMS_AUTHENTICATION_EMAIL_SERVICE_PARAMETERS}."
	date: "$Date$"
	revision: "$Revision$"

class
	CMS_AUTHENTICATION_EMAIL_SERVICE_PARAMETERS

inherit
	CMS_API_ACCESS

create
	make

feature {NONE} -- Initialization

	make (a_auth_api: CMS_AUTHENTICATION_API)
		local
			s: detachable READABLE_STRING_32
			l_utf8_site_name: IMMUTABLE_STRING_8
			l_contact_email: detachable READABLE_STRING_8
			l_cms_api: CMS_API
			p: PATH
		do
			auth_api := a_auth_api
			l_cms_api := a_auth_api.cms_api
			cms_api := l_cms_api
			create l_utf8_site_name.make_from_string (l_cms_api.setup.utf_8_site_name)
			utf_8_site_name := l_utf8_site_name
			notif_email_address := l_cms_api.setup.site_notification_email
			sender_email_address := l_cms_api.setup.site_email
			if not notif_email_address.has ('<') then
				notif_email_address := l_utf8_site_name + " <" + notif_email_address + ">"
			end
			mail_templates_location := l_cms_api.module_location_by_name ({CMS_AUTHENTICATION_MODULE}.name).extended ("mail_templates")
			if
				attached l_cms_api.module_configuration_by_name ({CMS_AUTHENTICATION_MODULE}.name, Void) as cfg
			then
				if attached cfg.text_item ("templates.mails.location") as loc then
					create p.make_from_string (loc)
					if not p.is_absolute then
						if attached p.components as l_comps and then not l_comps.is_empty and then l_comps.first.name.same_string ("site") then
							p := l_cms_api.site_location.parent.extended_path (p)
						else
							p := l_cms_api.site_location.extended_path (p)
						end

					end
					mail_templates_location := p
				end
				messages_config := cfg.sub_config ("messages")
				s := cfg.text_item ("contact_email")
				if s /= Void then
					l_contact_email := l_cms_api.utf_8_encoded (s)
				end
			end
			if l_contact_email = Void then
				l_contact_email := notif_email_address
			end
			if not l_contact_email.has ('<') then
				l_contact_email := l_utf8_site_name + " <" + l_contact_email + ">"
			end
			contact_email_address := l_contact_email
		end

feature {NONE} -- Config

	mail_templates_location: PATH

	messages_config: detachable like {CMS_API}.module_configuration_by_name
			-- Messages section of the config.

	subject_for_message (m: READABLE_STRING_GENERAL): detachable READABLE_STRING_8
		local
			k: STRING_32
		do
			create k.make_from_string_general (m)
			k.append (".subject")
			if
				attached messages_config as msg_cfg and then
				attached msg_cfg.text_item (k) as s
			then
				Result := cms_api.utf_8_encoded (s)
			end
		end

feature	-- Access

	auth_api: CMS_AUTHENTICATION_API

	cms_api: CMS_API

	notif_email_address: IMMUTABLE_STRING_8

	sender_email_address: IMMUTABLE_STRING_8

	contact_email_address: IMMUTABLE_STRING_8
			-- Contact email.

	utf_8_site_name: IMMUTABLE_STRING_8
			-- UTF-8 encoded Site name.

feature -- Access / Messages / Evaluation

	admin_account_registration_subject: READABLE_STRING_8
		do
			if attached subject_for_message ("admin_account_registration") as s then
				Result := s
			else
				Result := {IMMUTABLE_STRING_8} "New register, account evaluation."
			end
		end

	admin_account_registration_message: STRING
			-- Account evaluation template email message.
		do
			Result := template_string ("admin_account_registration.html", default_template_account_evaluation)
		end

feature -- Access / Messages / Registration

	user_registration_application_subject: IMMUTABLE_STRING_8
		do
			if attached subject_for_message ("user_registration_application") as s then
				Result := s
			else
				Result := {IMMUTABLE_STRING_8} "Thank you for registering with us."
			end
		end

	user_registration_application_message: STRING
			-- Account activation template email message.
		do
			Result := template_string ("user_registration_application.html", default_template_account_activation)
		end

feature -- Access / Messages / Password		

	user_reset_password_subject: IMMUTABLE_STRING_8
		do
			if attached subject_for_message ("user_reset_password") as s then
				Result := s
			else
				Result := {IMMUTABLE_STRING_8} "Password Recovery."
			end
		end

	user_reset_password_message: STRING
			-- Account password template email message.
		do
			Result := template_string ("user_reset_password.html", default_template_account_new_password)
		end

feature -- Access / Messages / Rejection		

	user_rejected_account_application_subject: IMMUTABLE_STRING_8
		do
			if attached subject_for_message ("user_rejected_account_application") as s then
				Result := s
			else
				Result := {IMMUTABLE_STRING_8} "Your account was rejected."
			end
		end

	user_rejected_account_application_message: STRING
			-- Account rejected template email message.
		do
			Result := template_string ("user_rejected_account_application.html", default_template_account_rejected)
		end

	accepted_account_application_subject: IMMUTABLE_STRING_8
		do
			if attached subject_for_message ("accepted_account_application") as s then
				Result := s
			else
				Result := {IMMUTABLE_STRING_8} "Your account was activated."
			end
		end

	accepted_account_application_message: STRING
			-- Account activation confirmation template email message.
		do
			Result := template_string ("user_accepted_account_application.html", default_template_account_activation_confirmation)
		end

feature -- Access / Messages / Verification - Activation	


	user_email_verification_subject: IMMUTABLE_STRING_8
		do
			if attached subject_for_message ("user_email_verification") as s then
				Result := s
			else
				Result := {IMMUTABLE_STRING_8} "Verify your email address."
			end
		end

	user_email_verification_message: STRING
			-- Account activation confirmation template email message.
		do
			Result := template_string ("user_email_verification.html", default_template_account_activation_confirmation)
		end

feature {NONE} -- Implementation: Template		

	template_path (a_name: READABLE_STRING_GENERAL): PATH
			-- Location of template named `a_name'.
		do
			Result := mail_templates_location.extended (a_name)
		end

	template_string (a_name: READABLE_STRING_GENERAL; a_default: STRING): STRING
			-- Content of template named `a_name', or `a_default' if template is not found.
		local
			p: PATH
		do
			p := template_path (a_name)
			if attached read_template_file (p) as l_content then
				Result := l_content
			else
				create Result.make_from_string (a_default)
			end
		end

feature {NONE} -- Implementation

	read_template_file (a_path: PATH): detachable STRING
			-- Read the content of the file at path `a_path'.
		local
			l_file: FILE
			n: INTEGER
		do
			create {PLAIN_TEXT_FILE} l_file.make_with_path (a_path)
			if l_file.exists and then l_file.is_readable then
				n := l_file.count
				l_file.open_read
				l_file.read_stream (n)
				Result := l_file.last_string
				l_file.close
			else
				-- Error	
			end
		end


feature {NONE} -- Message email

	default_template_account_evaluation: STRING = "[
		<!doctype html>
		<html lang="en">
		<head>
		  <meta charset="utf-8">
		  <title>Account Evaluation</title>
		  <meta name="description" content="Account Evaluation">
		  <meta name="author" content="$sitename">
		</head>

		<body>
		    <h2> Account Evaluation </h2>
			<p>The user $user ($email) wants to register to the site  <a href="$host">$sitename</a></p>

			<blockquote><p>This is his/her application.</p>
  				<p>$application</p>
			</blockquote>

			<p>To complete the registration, please click on the following link to activate the user account:<p>

			<p><a href="$activation_url">$activation_url</a></p>

			<p>To reject the registration, please click on the following link <p>

			<p><a href="$rejection_url">$rejection_url</a></p>
		</body>
		</html>
	]"


	default_template_account_activation: STRING = "[
		<!doctype html>
		<html lang="en">
		<head>
		  <meta charset="utf-8">
		  <title>Activation</title>
		  <meta name="description" content="Activation">
		  <meta name="author" content="$sitename">
		</head>

		<body>
			<p>Thank you for applying to  <a href="$host">$sitename</a> $user</p>

			<p>We will review your application and send you an email<p>
			<p>Thank you for joining us.</p>
		</body>
		</html>
	]"


	default_template_account_activation_confirmation: STRING = "[
		<!doctype html>
		<html lang="en">
		<head>
		  <meta charset="utf-8">
		  <title>Activation</title>
		  <meta name="description" content="Activation Confirmation">
		  <meta name="author" content="$sitename">
		</head>

		<body>
			<p>Your account has been confirmed  <a href="$host">$sitename</a> $email</p>

			<p>Thank you for joining us.</p>
		</body>
		</html>
	]"

	default_template_account_rejected:  STRING = "[
		<!doctype html>
		<html lang="en">
		<head>
		  <meta charset="utf-8">
		  <title>Application Rejected</title>
		  <meta name="description" content="Application Rejected">
		  <meta name="author" content="$sitename">
		</head>

		<body>
			<p>Your account application is rejected, it does not conform our rules <a href="$host">$sitename</a></p>
		</body>
		</html>
	]"

	default_template_account_re_activation: STRING = "[
		<!doctype html>
		<html lang="en">
		<head>
		  <meta charset="utf-8">
		  <title>New Activation</title>
		  <meta name="description" content="New Activation token">
		  <meta name="author" content="$sitename">
		</head>

		<body>
			<p>You have requested a new activation token at <a href="$host">$sitename</a></p>

			<p>To complete your registration, please click on the following link to activate your account:<p>

			<p><a href="$link">$link</a></p>
			<p>Thank you for joining us.</p>
		</body>
		</html>
	]"



	default_template_account_new_password: STRING = "[
		<!doctype html>
		<html lang="en">
		<head>
		  <meta charset="utf-8">
		  <title>New Password</title>
		  <meta name="description" content="New Password">
		  <meta name="author" content="$sitename">
		</head>

		<body>
			<p>You have requested a new password at <a href="$host">$sitename</a></p>

			<p>To complete your request, please click on this link to generate a new password:<p>

			<p><a href="$link">$link</a></p>
		</body>
		</html>
	]"


	default_template_account_welcome: STRING = "[
		<!doctype html>
		<html lang="en">
		<head>
		  <meta charset="utf-8">
		  <title>Welcome</title>
		  <meta name="description" content="Welcome">
		  <meta name="author" content="$sitename">
		</head>

		<body>
			<p>Welcome to <a href="$host">$sitename</a>.</p>
			<p>Thank you for joining us.</p>
		</body>
		</html>
	]"

end
