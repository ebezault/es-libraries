{unless isset="$user"}
<div class="login-box">
	<div class="description">
	Enter your username or the email address associated with your account. You'll receive a magic link by email that allows you to sign in.
	</div>
	<h3>Login{unless isempty="$site_register_url"} or <a href="{$site_url/}{$site_register_url/}">Register</a>{/unless}</h3>
	<div>
		<form name="cms_magic_link_auth" action="{$site_url/}account/auth/roc-magic-login" method="POST">
			{unless isempty="$site_destination"}<input type="hidden" name="destination" value="{htmlentities}{$site_destination/}{/htmlentities}">{/unless}
			<div>
				<input type="text" name="username" id="username" required value="{htmlentities}{$username/}{/htmlentities}">
				<label>Username or email</label>
			</div>
			<button type="submit">Continue</button>
		</form>
	</div>
	{if isset="$error"}<div class="error">{$error/}</div>{/if}
</div>
{/unless}
